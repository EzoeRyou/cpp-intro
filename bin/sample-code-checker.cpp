#include <iostream>
#include <fstream>
#include <string>
#include <new>
#include <iterator>
#include <regex>
#include <atomic>
#include <stdexcept>

#include <sys/stat.h>
#include <sys/types.h>



std::string all_std_headers = R"(
#include <cstddef>
#include <limits>
#include <climits>
#include <cfloat>
#include <cstdint>
#include <cstdlib>
#include <new>
#include <typeinfo>
#include <exception>
#include <initializer_list>
#include <cstdalign>
#include <stdexcept>
#include <cassert>
#include <cerrno>
#include <system_error>
#include <string>

#include <array>
#include <deque>
#include <forward_list>
#include <list>
#include <vector>
#include <map>
#include <set>
#include <unordered_map>
#include <unordered_set>
#include <queue>
#include <stack>
#include <iterator>
#include <algorithm>
#include <cfenv>
#include <random>
#include <numeric>
#include <cmath>
#include <iosfwd>
#include <iostream>
#include <ios>
#include <streambuf>
#include <istream>
#include <ostream>
#include <iomanip>
#include <sstream>
#include <fstream>

#include <filesystem>

#include <cstdio>
#include <cinttypes>
#include <csetjmp>

#include <regex>
#include <atomic>
#include <thread>
#include <mutex>
#include <shared_mutex>
#include <condition_variable>
#include <future>

)" ;   

std::string get_unique_file_name()
{
    static std::atomic<unsigned> value ;

    return std::string("/tmp/sample-code-checker/") + std::to_string(++value) + std::string(".cpp") ;
}

std::string create_temp_source_file( std::string sample_code )
{
    auto file_name = get_unique_file_name() ;
    std::ofstream file( file_name, std::ios_base::out | std::ios_base::trunc ) ;

    file.write( sample_code.c_str(), sample_code.size() ) ;
    return file_name ;

}


bool compile_check_gcc( std::string const & file_name )
{
    std::string command = std::string("g++ -fsyntax-only -D _ISOC11_SOURCE -std=c++1z --pedantic-errors -Wall -pthread -include /tmp/sample-code-checker/all_std_headers.hpp ") + file_name ;

    int result = system( command.c_str() ) ;

    return result == 0 ;

}

bool compile_check_clang( std::string const & file_name )
{
    std::string command = std::string("clang++ -fsyntax-only -D _ISOC11_SOURCE -std=c++1z -stdlib=libc++ --pedantic-errors -Wall -pthread -include-pch /tmp/sample-code-checker/all_std_headers.hpp.pch ") + file_name ;

    int result = system( command.c_str() ) ;

    return result == 0 ;

}



bool compile_check( std::string const & file_name )
{
    return
        compile_check_gcc( file_name )
            &&
        compile_check_clang( file_name ) ;
}

// check if a given sample code is a well-formed C++ code fragment
void check_sample_code( std::string sample_code )
{

    auto file_name = create_temp_source_file( sample_code ) ;


    bool result = compile_check( file_name ) ;


    if ( result )
    {
        remove( file_name.c_str() ) ;
    }
    else
    {
        //throw std::logic_error("compilation failed.") ;
    }

}

// grep all sample code in a file.
void check_source_file( char const * file_name )
{
    std::cout << "checking: " << file_name << std::endl ;

    // read the entire text file to the memory
    std::ifstream file{ file_name } ;
    std::string text{ std::istreambuf_iterator<char>{file}, std::istreambuf_iterator<char>{} } ;


    // search for each sample code
    std::regex pattern{ R"(~~~cpp([^]*?)~~~)" } ;

    std::sregex_iterator iter{ text.cbegin(), text.cend(), pattern } ;
    std::sregex_iterator end ;

    std::for_each( iter, end,
        []( auto && match_result )
        {
            auto && sample_code = match_result[1].str() ;

            check_sample_code( sample_code ) ;
        }
    ) ;
}

// prepare compiling by
// creating tmp/sample-code-checker directory
// generate precompiled header file.
bool prepare_compile()
{
    mkdir("/tmp/sample-code-checker",   S_IRWXU | S_IRWXG) ;

    {
        std::ofstream precompiled_header("/tmp/sample-code-checker/all_std_headers.hpp" ) ;

        precompiled_header.write( all_std_headers.c_str(), all_std_headers.size() ) ;
    }

    int r1 = std::system("g++ -D _ISOC11_SOURCE -std=c++1z --pedantic-errors -Wall -pthread -x c++-header -o /tmp/sample-code-checker/all_std_headers.hpp.gch /tmp/sample-code-checker/all_std_headers.hpp") ;
    
    int r2 = std::system("clang++ -D _ISOC11_SOURCE -std=c++14 --pedantic-errors -Wall -pthread -x c++-header -o /tmp/sample-code-checker/all_std_headers.hpp.pch /tmp/sample-code-checker/all_std_headers.hpp") ;

    return r1 == 0 && r2 == 0 ;
}


// compile each file
void retest( char ** argv )
{
    std::cout << "retest" << std::endl ;
    for (   char ** iter = argv + 2 ;
            *iter != nullptr ;
            ++iter )
    {
        bool result = compile_check( std::string( *iter ) ) ;
        if ( result )
        {
            std::cout << "test pass: " << *iter << std::endl ;
        }
    }
}

void test( char ** argv )
{
    // for each file name in arguments
    for (   char ** iter = argv + 1 ;
            *iter != nullptr ;
            ++iter )
    {
        check_source_file( *iter ) ;
    }

}

int main( int argc, char ** argv )
{

    prepare_compile() ;

    if ( std::string("retest").compare(argv[1]) == 0 )
    {
        retest( argv ) ;
    }
    else
    {
        test( argv ) ;
    }



}
