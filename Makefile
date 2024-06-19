all: check_gtest build_dir cmake_build test gcov_report

build_dir:
	mkdir -p build

cmake_configure: build_dir
	cd build && cmake -DCMAKE_BUILD_TYPE=Coverage ..

cmake_build: cmake_configure
	cd build && cmake --build .

test: cmake_build
	cd build && ./run_tests

test_val: test
	valgrind --tool=memcheck --leak-check=yes --track-origins=yes -s ./build/run_tests
	
gcov_report:
	cd build && cmake --build . --target coverage

clean:
	rm -rf build

rebuild: clean all

check_gtest:
	@if [ ! -d "/usr/include/gtest" ] && [ ! -d "external/googletest" ]; then \
		echo "Google Test not found, cloning..."; \
		mkdir -p external; \
		cd external; \
		git clone https://github.com/google/googletest.git; \
	fi