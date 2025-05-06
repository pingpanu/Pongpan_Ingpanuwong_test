function brickWall(array) {
    const row = array.length;
        
    /*output should be initiate with the array[0]
    because I would place brick per wall height at the starting position
    array[0]*/
    let output = array[0];

    /*The iteration start at 1, indicate the next position,
    because I want to compare two position; current and next
    then calculate the brick required*/
    for (let i = 1; i < row; i++) {
        if (array[i - 1] < array[i]) {
            output += array[i] - array[i - 1]; 
        }
    }
    return output;
}

const arr1 = [1,2,3,4,5,6];
const arr2 = [1,2,2,1,5,6];

console.log(brickWall(arr1));
console.log(brickWall(arr2));