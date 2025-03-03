
runmodel.checkForError <- function(obj, warnStr="ERROR", objStr="", rem.obj=NULL, msg=NULL) {

  if ("try-error" %in% class(obj)) {
    #if (is.null(msg)) msg <- runModel.getErrorMsg(obj)
    if (is.null(msg)) msg <- getErrorMsgFromTryError(obj, addToEnd=NULL)
    tmp <- list()
    tmp[[runModel.getWarningCol()]] <- warnStr
    tmp[[runModel.getObjectCol()]]  <- objStr
    tmp[[runModel.getMessageCol()]] <- msg
    rem.obj <- runmodel.addWarning(rem.obj, tmp)
  }
  rem.obj

}

runmodel.addWarning <- function(obj, newList) {

  if (!length(newList)) return(obj)
  c1 <- runModel.getWarningCol()
  c2 <- runModel.getObjectCol()
  c3 <- runModel.getMessageCol()
  x1 <- newList[[c1, exact=TRUE]]
  x2 <- newList[[c2, exact=TRUE]]
  x3 <- newList[[c3, exact=TRUE]]
  if (!length(x1)) x1 <- ""
  if (!length(x2)) x2 <- ""
  if (!length(x3)) x3 <- ""
  new <- cbind(x1, x2, x3)
  if (is.null(obj)) {
    obj           <- new
    colnames(obj) <- c(c1, c2, c3)
  } else {
    obj <- rbind(obj, new)
  }

  obj

} # END: runModel.addWarning

runModel.addRemVars <- function(obj, vars, type, reason, printWarning=1, varMap=NULL,
                                errType="WARNING") {

  if (!is.null(varMap)) vars <- runModel.varMap(vars, varMap)

  msg       <- paste("variable removed from ", type, ": ", reason, sep="")
  c1        <- runModel.getWarningCol()
  c2        <- runModel.getObjectCol()
  c3        <- runModel.getMessageCol()
  tmp       <- list()
  tmp[[c1]] <- errType
  tmp[[c2]] <- vars
  tmp[[c3]] <- msg
  obj       <- runmodel.addWarning(obj, tmp)

  if (printWarning) {
    str <- paste(vars, collapse=", ", sep="") 
    msg <- msg_mod_16(c(str, type, reason))
    warning(msg)
  }

  obj

} # END: runModel.addRemVars

runModel.getRemMessage <- function(rem.obj, vars, collapse=NULL, varMap=NULL) {

  n   <- length(vars)
  ret <- rep("", n)
  if (!length(rem.obj)) return(ret)
  if (!is.null(varMap)) vars <- runModel.varMap(vars, varMap)

  v    <- runModel.getObjectCol()
  rows <- match(vars, rem.obj[, v])
  tmp  <- !is.na(rows)
  rows <- rows[tmp]
  if (!length(rows)) return(ret)
  v        <- runModel.getMessageCol()
  ret[tmp] <- rem.obj[rows, v]
  if (length(collapse)) ret <- paste(ret, collapse=collapse, sep="")

  ret

} # END: runModel.getRemMessage

getErrorMsgFromTryError <- function(obj, addToEnd=NULL) {

  ret <- NULL
  if ("try-error" %in% class(obj)) {
    msg <- attr(obj, "condition")
    ret <- msg[["message", exact=TRUE]]
  }
  if (length(addToEnd) && length(ret)) ret <- paste0(ret, addToEnd) 

  ret

} # END: getErrorMsgFromTryError

runModel.getErrorMsg <- function(obj) {

  ret <- paste(as.character(obj), collapse=" ", sep="")
  ret <- gsub("\n", " ", ret, fixed=TRUE)
  ret <- gsub("\r", " ", ret, fixed=TRUE)

  ret

} # END: runModel.getErrorMsg

runModel.getVarsRemoved <- function(rem.obj, type="adjvars") {

  if (!length(rem.obj)) return(NULL)

  ret <- NULL
  col <- runModel.getMessageCol()
  str <- paste(type, ":", sep="")
  tmp <- grepl(str, rem.obj[, col], fixed=TRUE)
  if (any(tmp)) ret <- unique(rem.obj[tmp, runModel.getObjectCol(), drop=TRUE])
  
  ret

} # END: runModel.getVarsRemoved
