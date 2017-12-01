## makeCacheMatrix creates a matrix and a set of setter and getter functions
## for its value and for the value of its inverse.
## cacheSolve returns the inverse of the matrix from cache, if already stored;
## or calculates it, if not already stored.

## Create a matrix (x) and initialise the value of its inverse (inv)

makeCacheMatrix <- function(x = matrix()) {
        inv <- NULL
        
        #A function to set the value of the matrix
        set <- function(y) {
                x <<- y
                inv <<- NULL
        }
        
        #A funtion to get the value of the matrix
        get <- function() x
        
        #A function to set the value of the inverse
        setinv <- function(inverse) inv <<- inverse
        
        #A function to get the value of the inverse
        getinv <- function() inv
        
        #A list with all the getter and setter functions
        list(set = set, get = get, setinv = setinv, getinv = getinv)

}


## Check if the value of the inverse has already been calculated and stored in cache. If yes, retrieve it from cache.
## If not, calculate the inverse and store it. Print the inverse.

cacheSolve <- function(x, ...) {
        #Return a matrix that is the inverse of 'x'
        inv <- x$getinv()
        
        #Check if the value of the inverse has already been cached. If yes, retrieve from cache.
        if(!is.null(inv)) {
                message("getting cached data")
                return(inv)
        }
        
        ## If the inverse has not been cached already, then:
        
        #Get the value of the matrix
        matrix <- x$get()
        
        #Calculate the inverse of the matrix
        inv <- solve(matrix)
        
        #Set the value of the inverse
        x$setinv(inv)
        
        #Print the value of the inverse
        inv
}
