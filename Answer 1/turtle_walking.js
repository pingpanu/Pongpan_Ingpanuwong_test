function turtleWalk(matrix) {
    /* I use string because if I use console.log(arr[j][i] + ',')
    there will be the excess "," at the end of the output line
    and it's really complicated to not print the "," after the last number because
        -> The last number of the matrix depend on whether the matrix column (col) is odd or even
            -> If it's odd, the last number of matrix is arr[row][col] because the turtle move South (down)
            -> If it's even, the last number of matrix is arr[0][col] because the turtle move North (up)
        -> Since we 'ALWAYS' have to not print the last "," only, it's shorter to just remove the trailing comma
           then console.log(output)
    */
    let output = "";

    /* In Javascript, user can pass ANY type of variables to function
    (and this weakness led to the creation of Typescript) so the int variable
    indicating row and column of the matrix is required (unlike C or C++)
    */
    const row = matrix.length;
    const col = matrix[0].length;

    /*
        The turtle move South (down) first, then it move North (up) when it enter next column, 
        then flip again when enter next column
        It's mean that if column_pointer (i) is 0 or even, the turtle move South
        then if column_pointer (i) is odd, the turtle move North

        Noted that the pointer sequence start with 0, not 1 like conventional counting.
    */
    for (let i = 0; i < col; i++) {
        for (let j = 1; j <= row; j++) {
            if (i % 2 === 0) {
                output += matrix[j - 1][i].toString() + ",";
            } else {
                output += matrix[row - j][i].toString() + ",";
            }
            /*string can be concat by using += string in JavaScript
            in this case, I converted matrix[j][i] to string then concat both
            matrix[j][i].toString() and "," to output
            */
        }
    }

    // Remove the trailing comma
    output = output.slice(0, -1);
    console.log(output);
}

// Example matrices
const arr1 = [
    [7, 2, 0, 1, 0, 2, 9],
    [8, 4, 8, 6, 9, 3, 3],
    [7, 8, 8, 8, 9, 0, 6],
    [4, 7, 2, 7, 0, 0, 7],
    [6, 5, 7, 8, 0, 7, 2],
    [8, 1, 8, 5, 4, 5, 2]
];

const arr2 = [
    [7, 2, 0],
    [8, 4, 8],
    [7, 8, 8]
];

const arr3 = [
    [7, 2, 0],
    [8, 4, 8]
];

turtleWalk(arr1);
turtleWalk(arr2);
turtleWalk(arr3);