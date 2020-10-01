#!/bin/bash
TEST_SCRIPT="./helper.sh"

SZ_10MB=10485760
SZ_1MB=1048576
SZ_64KB=65536
SZ_32KB=32768
SZ_16KB=16384
SZ_8KB=8192
SZ_4KB=4096
SZ_1KB=1024
SZ_100B=100

function export_vars() {
	export TEST
	export PAYLOAD_SZ
	export INFILE
	export TIMEOUT
}

echo -e "********************************************"
echo -e "*********Test Script - CS 456/656***********"
echo -e "********************************************\n"

echo -e "Testing make all..."
echo -e "-------------------------------------------"
make all
echo "make all finished"
echo -e "-------------------------------------------\n\n\n"

echo -e "Checking if receiver and sender exist..."
echo -e "-------------------------------------------"
if [[ -f "receiver" ]] && [[ -f "sender" ]]
then
	echo "sender and receiver exist!"
else
	echo "trouble making sender and receiver executables."
	exit 0
fi
echo -e "-------------------------------------------\n\n\n"

echo "Creating test files:"
echo -e "-------------------------------------------"
dd if=/dev/urandom of=file_100B count=1 bs=${SZ_100B}
dd if=/dev/urandom of=file_4KB count=1 bs=${SZ_4KB}
dd if=/dev/urandom of=file_64KB count=1 bs=${SZ_64KB}
dd if=/dev/urandom of=file_1MB count=1 bs=${SZ_1MB}
echo "Finishing creating test files"
echo -e "-------------------------------------------\n\n\n"



# Test 1: Illegal input - <file name> (file non-existent)
TEST=1
PAYLOAD_SZ=128
INFILE="nonexistent_file"
TIMEOUT=1000
export_vars
("$TEST_SCRIPT")

# Test 2: Illegal input - <file name> (no permission)
NO_READ_TEST_FILE="no_read_test_file"
(cp "file_100B" "$NO_READ_TEST_FILE") && (chmod 333 "$NO_READ_TEST_FILE")
TEST=2
PAYLOAD_SZ=128
INFILE=$NO_READ_TEST_FILE
TIMEOUT=1000
export_vars
("$TEST_SCRIPT")

# Test 3: Illegal input - <payload size>
TEST=3
PAYLOAD_SZ=-1
INFILE=file_4KB
TIMEOUT=1000
export_vars
("$TEST_SCRIPT")

# Test 4: Illegal input - <timeout>
TEST=4
PAYLOAD_SZ=128
INFILE=file_4KB
TIMEOUT=-1
export_vars
("$TEST_SCRIPT")


# Test 5: len(<file>) < <payload size> (100 bytes < 512 bytes)
# Expects that 	~100B transferred
#				ceil(100/512)+1 = 1+1 packets transferred
#				t5_output matches file_100B
TEST=5
PAYLOAD_SZ=512
INFILE=file_100B
TIMEOUT=1000
export_vars
("$TEST_SCRIPT")

# Test 6: Virtual File size 16KB
# Expects that 	~16KB = 65536B transferred 
#		 		ceil(16000/1024)+1 = 16+1 packets transferred
#		 		t6_output is of size = 16KB
TEST=6
PAYLOAD_SZ=1024
INFILE=$SZ_16KB #Passing number not file
TIMEOUT=4000
export_vars
("$TEST_SCRIPT")


# Test 7: len(<file>) > <payload size> (4K bytes > 256 bytes)
# Expects that 	~4KB transferred
#				ceil(4096/512)+1 = 16+1 packets transferred
#				t7_output matches file_4KB
TEST=7
PAYLOAD_SZ=256
INFILE=file_4KB
TIMEOUT=4000
export_vars
("$TEST_SCRIPT")


# Test 8: len(<file>) > <payload size> (1M bytes > 2048 bytes)
# Expects that 	~1MB transferred or less due to packet loss
#				ceil(1048576/2048)+1 = 512+1 packets transferred
#				less than or equal to 513 packets received
#				t8_output matches file_1MB (or not)
TEST=8
PAYLOAD_SZ=2048
INFILE=file_1MB
TIMEOUT=10000
export_vars
("$TEST_SCRIPT")

# Test 9: Virtual File size 1MB - Large Message Count
# Expects that 	~1MB transferred or less due to packet loss
#				ceil(1048576/256)+1 = 4096+1 packets transferred
#				less than or equal to 4097 packets received
#				t9_output is of size 1MB
TEST=9
PAYLOAD_SZ=256
INFILE=$SZ_1MB
TIMEOUT=10000
export_vars
("$TEST_SCRIPT")

# Test 10: Virtual File size 10MB - Large Message Count - TIMEOUT
# Expects that 	~1MB transferred or less due to packet loss
#				ceil(10485760/2048)+1 = 5120+1 packets transferred
#				less than or equal to 5121 packets received
#				t9_output is of size 10MB (maybe way less because of the timeout)
TEST=10
PAYLOAD_SZ=2048
INFILE=$SZ_10MB
TIMEOUT=1000
export_vars
("$TEST_SCRIPT")






echo "Tests Done. Press Enter to clean up files and exit."
read junk

# cleaning generated files in the folder
echo -e "Cleaning generated files..."
echo -e "-------------------------------------------\n"
rm -f file_*
rm -f *_output
rm -f port
rm -f receivedFile
rm -f no_read_test_file
make clean
echo -e "File created are removed."
echo -e "\n-------------------------------------------\n\n\n"
echo "Exiting..."



