# This file is part of digitizeR
# 
# digitizeR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# digitizeR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with digitizeR.  If not, see <http://www.gnu.org/licenses/>.

testList <- list(a = function() { print("a") })
testFn <- function() {
    p <- rjson::fromJSON('{"x": 1}')
    print(p)
    print(system.file(package="digitizeR"))
}