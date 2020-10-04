# Usage
1. Login ubuntu student cs environment.
2. Unzip a student's zip submission into a folder (e.g. /a1)
3. Copy test.sh and helper.sh into the student's assignment folder created in Step 2. 
4. Make sure ```test.sh``` and ```helper.sh``` are executables. 
Run ```chmod +x test.sh helper.sh```
5. Run ```./test.sh```
6. Check on the output for each test and compares with the comment in test.sh

# Notes
* This is a modified version from Stefanie's script because I couldn't get her script to run for my students ``;(``. First 6 tests are from Stefanie and I added the rest.
* Those following tests may not be enough to cover every scenario. New tests are welcome and appreciated.
* Please run the script and understand the tests, to make sure they make sense. (It will most certainly have some errors here and there since it's my first time being a TA and I'm not a shell script expert ``;(``)
* Script should work for all 4 languages, as long as the student follows the assignment about generating ``sender`` and ``receiver`` executables.
* ``receiver`` and ``sender `` are both run on the same machine using this script, so using ``localhost`` as the host address. Need to manually check the code to determine if a student is hardcoding ``localhost`` as the `host` or not.
* The script runs the following tests in sequence.
* On done, the script block for you to inspect generated files.
* If you want to terminate the script after it runs all the tests, follow the prompt on the terminal, press ``Enter`` to clean up generated files.

# Tests
* Test 1: Illegal input - file name (file non-existent)
* Test 2: Illegal input - file name (no permission)
* Test 3: Illegal input - payload size
* Test 4: Illegal input - timeout
* Test 5: len(file) < payload size (100 bytes < 512 bytes)
  * Expects that 	
    * ~100B transferred
	* ceil(100/512)+1 = 1+1 packets transferred
    * t5_output matches file_100B
* Test 6: Virtual File size 16KB
  * Expects that 	
    * ~16KB = 65536B transferred
    * ceil(16000/1024)+1 = 16+1 packets transferred
    * t6_output is of size = 16KB
* Test 7: len(<file>) > <payload size> (4K bytes > 256 bytes)
  * Expects that 
    * ~4KB transferred
    * ceil(4096/512)+1 = 16+1 packets transferred
    *	t7_output matches file_4KB
* Test 8: len(<file>) > <payload size> (1M bytes > 2048 bytes)
  * Expects that
    * ~1MB transferred or less due to packet loss
    * ceil(1048576/2048)+1 = 512+1 packets transferred
    * less than or equal to 513 packets received
    * t8_output matches file_1MB (or not)
* Test 9: Virtual File size 1MB - Large Message Count
  * Expects that
    * ~1MB transferred or less due to packet loss
    * ceil(1048576/256)+1 = 4096+1 packets transferred
    * less than or equal to 4097 packets received
    * t9_output is of size 1MB
* Test 10: Virtual File size 10MB - Large Message Count - TIMEOUT
  * Expects that
    * ~1MB transferred or less due to packet loss
    * ceil(10485760/2048)+1 = 5120+1 packets transferred
    * less than or equal to 5121 packets received
    * t10_output is of size 10MB (maybe way less because of the timeout)