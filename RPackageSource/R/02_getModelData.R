#---------------------------------------------------------
# Get Model data and model components --------------------
#---------------------------------------------------------
#' Prepares data for the models to be run as specified in the input.  Can be run in interactive or batch mode.  Each model is checked for validity (correlation between predictors, zero variance, etc.).
#'
#' @param readData List from \code{\link{readCOMETSinput}}
#' @param modelspec How model is specified (Interactive or Batch). The default is Batch
#' @param modlabel  If batch, chosen model specified by batch mode (the MODEL column in
#'                  the Models sheet). If interactive, then the model label.
#' @param outcomes   If Interactive, a vector of outcome variables (see \code{details}), the default is All metabolites)
#' @param exposures  If Interactive, a vector of exposure variables (see \code{details})
#' @param adjvars   If Interactive, a vector adjustment covariates (see \code{details})
#' @param strvars   If Interactive, stratification covariates (see \code{details})
#' @param wgtvar    If Interactive, a variable of weights (see \code{details})
#' @param offvar    If Interactive, an offset variable (see \code{details})
#' @param timevar   If Interactive, time variable(s) for survival models (see \code{details})
#' @param groupvar  If Interactive, a group variable for conditional logistic models (see \code{details})
#' @param where users can specify which subjects to perform the analysis on by specifying this parameter. 
#'        'where' expects a vector of strings with a variable name, 
#'        a comparison operator (e.g. "<", ">", "<=", ">=", "!=", "="), and a value.  
#'        For example, \code{where = c("age>50","bmi > 22")} uses all subjects
#'        with age > 50 AND bmi > 22.  
#'     Note that when running in Batch mode, rules in the \code{WHERE} column
#'     of the \code{Models} sheet must be separated by a comma.
#' @param exposurerefs  If Interactive, a vector of exposure reference levels for
#'        categorical exposure variables. If specified, then this vector must
#'        have the same length as \code{exposures}.
#'
#' @details All metabolite variables specified should be listed in the \code{metabolite_name}
#'   column of the \code{Metabolites} sheet of the Excel file. All non-metabolite
#'   variables should be listed in the \code{VARREFERENCE} column of the
#'   \code{VarMap} sheet. The \code{wgtvar}, \code{offvar}, and \code{timevar} are only used
#'   for specific models. See the
#'   \code{model} option in \code{\link{options}}.
#'
#' @return a list comprising: \cr
#' 1: subset data: gdta \cr
#' 2: exposure variables: ccovs \cr
#' 3: outcome variables: rcovs \cr
#' 4: adjustment variables: acovs \cr
#' 5: stratification variable: scovs \cr
#' 6: model specification: modspec \cr
#' 7: model label: modlab \cr
#' 8: whether all metabolites vs all metabolites is run: allvsall \cr
#' 9: weight variables: wgtcov \cr
#' 10: offset variables: offcov
#'
#' @examples
#' dir <- system.file("extdata", package="RcometsAnalytics", mustWork=TRUE)
#' csvfile <- file.path(dir, "cometsInputAge.xlsx")
#' exmetabdata <- readCOMETSinput(csvfile)
#' modeldata <- getModelData(exmetabdata,modlabel="1 Gender adjusted")
#'
#' @export

getModelData <-  function(readData,
                          modelspec    = "Batch",
                          modlabel     = "",
                          outcomes     = "All metabolites",
                          exposures    = "",
                          adjvars      = NULL,
                          strvars      = NULL,
                          wgtvar       = NULL,
                          offvar       = NULL,
                          timevar      = NULL,
                          groupvar     = NULL,
			  where        = NULL,
                          exposurerefs = NULL) {

  rowvars   <- outcomes
  colvars   <- exposures
  modelspec <- check.string(modelspec, c(getMode_interactive(), getMode_batch()), "modelspec")
  
  allvsall    <- FALSE
  rem.obj     <- NULL
  options     <- NULL
  acovs       <- NULL
  scovs       <- NULL
  wgtcov      <- NULL
  offcov      <- NULL
  timecov     <- NULL
  groupcov    <- NULL
  runCorrFlag <- 0

  # All original metabolite names
  allmetabs   <- readData$dict_metabnames
  tmp         <- !(allmetabs %in% readData$subjId0)
  allmetabs   <- allmetabs[tmp]
  allmetabStr <- getAllMetabsName()

  # figure out the model specification based on type (Interactive or Batch)
  if (modelspec == getMode_interactive()) {
    if(any(colvars=="")) {stop(msg_gmd_1())}

    # Normalize variables so that it is consistent with readCOMETSinput
    rowvars  <- checkVariableNames(rowvars,  "outcomes",  default=allmetabStr, only.unique=1)
    colvars  <- checkVariableNames(colvars,  "exposures", default="",   only.unique=1)
    adjvars  <- checkVariableNames(adjvars,  "adjvars",   default=NULL, only.unique=1)
    strvars  <- checkVariableNames(strvars,  "strvars",   default=NULL, only.unique=1)
    wgtvar   <- checkVariableNames(wgtvar,   "wgtvar",    default=NULL, only.unique=1, max.n=1)
    offvar   <- checkVariableNames(offvar,   "offvar",    default=NULL, only.unique=1, max.n=1)
    timevar  <- checkVariableNames(timevar,  "timevar",   default=NULL, only.unique=1, max.n=2)
    groupvar <- checkVariableNames(groupvar, "groupvar",  default=NULL, only.unique=1, max.n=1)

    # Check that all variables that are input by user exist in the renamed data
    allvars <- c(setdiff(c(rowvars,colvars,adjvars,strvars,wgtvar,offvar,timevar,groupvar),allmetabStr))
    subjmetab <- as.character(lapply(colnames(readData$subjdata), function(x) {
        myind <- which(names(readData$dict_metabnames)==x)
        if(length(myind==1)) {x=readData$dict_metabnames[myind]}
        return(x) }))
    tmp <- is.na(match(allvars,subjmetab))
    if(any(tmp)) {
      msg <- infile.collapseVec(allvars[tmp], sep=", ", begin="<", end=">", removeMiss=1)
      msg <- msg_gmd_2(msg)
      stop(msg)
    }

    # Rename outcome variables
    tmp <- rowvars %in% allmetabStr
    if (any(tmp)) rowvars <- unique(c(rowvars[!tmp], allmetabs))
    rcovs <- runModel.getNewVarName(rowvars, readData$dict_metabnames)
   
    # Rename exposure variables
    tmp <- colvars %in% allmetabStr
    if (any(tmp)) colvars <- unique(c(colvars[!tmp], allmetabs))
    ccovs <- runModel.getNewVarName(colvars, readData$dict_metabnames)

    # rename the adjustment variables
    if (!is.null(adjvars)) {
      tmp   <- unlist(strsplit(adjvars, " "))
      acovs <- runModel.getNewVarName(tmp, readData$dict_metabnames)
    } 

    # rename the stratification variables
    if (!is.null(strvars)) {
      tmp   <- unlist(strsplit(strvars, " "))
      scovs <- runModel.getNewVarName(tmp, readData$dict_metabnames)
    } 

    # rename the weight variable
    if (!is.null(wgtvar)) {
      wgtcov <- runModel.getNewVarName(wgtvar, readData$dict_metabnames)
    } 

    # rename the offset variable
    if (!is.null(offvar)) {
      offcov <- runModel.getNewVarName(offvar, readData$dict_metabnames)
    } 

    # rename the time variable
    if (!is.null(timevar)) {
      timecov <- runModel.getNewVarName(timevar, readData$dict_metabnames)
    } 

    # rename the group variable
    if (!is.null(groupvar)) {
      groupcov <- runModel.getNewVarName(groupvar, readData$dict_metabnames)
    } 

    # Assign allvsall variable
    allvsall <- FALSE
    if ( (length(colvars) == 1) && (length(rowvars) == 1) ) {
      if ( (colvars == allmetabStr) && (rowvars==allmetabStr) ) {
        allvsall <- TRUE
      }
    } 

    # Check exposurerefs
    m <- length(exposurerefs)
    if (m && (m != length(exposures))) stop(msg_gmd_3())

    # end if modelspec is "Interactive"

  } else if (modelspec == getMode_batch()) {
    # here we need to get the covariates defined from the excel sheet
    # step 1. get the chosen model first

    if (modlabel == "") {
      msg <- msg_gmd_4()
      stop(msg)
    }

    # defining global variable to remove Rcheck warnings
    model = c()

    # integrity check for unmatch modlabel -------------------------------------
    mods <- dplyr::filter(as.data.frame(readData[["mods"]]), model == modlabel)
    if (nrow(mods) == 0) {
      tmp <- msg_gmd_5(modlabel)
      stop(tmp)
    } else if (nrow(mods) > 1) {
      tmp <- msg_gmd_6(modlabel)
      stop(tmp)
    }

    # rename variables to cohortvariable definitions -----------------------------

    # assign outcome vars -------------------------
    rcovs <- getCovNames_allMetabs(mods$outcomes, allmetabs, readData$dict_metabnames)

    # assign exposure vars -------------------------
    ccovs <- getCovNames_allMetabs(mods$exposure, allmetabs, readData$dict_metabnames)

    # assign adjustment vars -------------------------
    if (!is.na(mods$adjustment)) {
      acovs <- as.vector(strsplit(mods$adjustment, " ")[[1]])
      acovs <- runModel.getNewVarName(unique(trimws(acovs)), readData$dict_metabnames)
    } 

    # assign stratification vars vars -------------------------
    if (!is.na(mods$stratification)) {
      scovs <- as.vector(strsplit(mods$stratification, " ")[[1]])
      scovs <- runModel.getNewVarName(unique(trimws(scovs)), readData$dict_metabnames)
    } 

    # assign time vars -------------------------
    timeColName <- tolower(getModelsTimeCol())
    timeCol     <- mods[[timeColName, exact=TRUE]]
    if (!is.null(timeCol) && !is.na(timeCol)) {
      timecov <- as.vector(strsplit(timeCol, " ")[[1]])
      timecov <- runModel.getNewVarName(unique(trimws(timecov)), readData$dict_metabnames)
    } 

    # assign group vars -------------------------
    groupColName <- tolower(getModelsGroupCol())
    groupCol     <- mods[[groupColName, exact=TRUE]]
    if (!is.null(groupCol) && !is.na(groupCol)) {
      groupcov <- as.vector(strsplit(groupCol, " ")[[1]])
      groupcov <- runModel.getNewVarName(unique(trimws(groupcov)), readData$dict_metabnames)
    } 

    # Get the options for this model
    options <- getAllOptionsForModel(mods, readData)
    if (is.null(options)) options <- list()

    # Determine if runCorr is the function to be called
    runCorrFlag <- options[[getOldCorrModelName(), exact=TRUE]]
    if (is.null(runCorrFlag)) runCorrFlag <- 0 
    options[[getOldCorrModelName()]] <- NULL

    # Get weight, offset variables
    wgtvar  <- NULL
    offvar  <- NULL
    mop     <- options[[getModelOpsName(), exact=TRUE]]
    if (length(mop)) {
      wgtvar <- mop[["weights", exact=TRUE]]
      if (length(wgtvar)) wgtcov <- runModel.getNewVarName(wgtvar, readData$dict_metabnames)
      offvar <- mop[["offset", exact=TRUE]]
      if (length(offvar)) offcov <- runModel.getNewVarName(offvar, readData$dict_metabnames)
    }  

    # assign where filtering -------------------------
    if (!is.na(mods$where)) {
      where <- mods$where
    } else {
      where <- NULL
    }

    # Get the exposure refs, checked when readCometsInput is called
    exposurerefs <- mods[[tolower(getModelsExpRefCol()), exact=TRUE]]
    if (!is.character(exposurerefs)) exposurerefs <- NULL
    if (length(exposurerefs)) exposurerefs <- parseStr(exposurerefs, sep=runModel.getVarSep())   
  } # end if modelspec == "Batch"

  # Check that the variables exist in the renamed data
  allvars <- c(rcovs,ccovs,acovs,scovs, wgtcov, offcov, timecov)
  tmp     <- is.na(match(allvars,colnames(readData$subjdata)))
  if (any(tmp)) {
    str <- paste(allvars[tmp], collapse=", ", sep="")
    msg <- msg_gmd_7(str)
    stop(msg)
  }

  # Check variables
  tmp     <- checkAllVariables(rem.obj, rcovs, ccovs, adjvars=acovs, stratvars=scovs, timevars=timecov)
  rem.obj <- tmp[["rem.obj", exact=TRUE]]
  rcovs   <- tmp[["outcomes", exact=TRUE]]
  ccovs   <- tmp[["exposures", exact=TRUE]]

  # Keep only needed variables for the data -------------------------------
  # build list of variables
  covlist <- c(ccovs, rcovs)
  if (!is.null(acovs)) covlist <- c(covlist, acovs)
  if (!is.null(scovs)) covlist <- c(covlist, scovs)
  covlist <- c(covlist, wgtcov, offcov, timecov, groupcov)
  varMap  <- NULL
  if (length(wgtvar) || length(offvar)) {
    varMap        <- c(wgtvar, offvar)
    names(varMap) <- c(wgtcov, offcov)
  }

  if (!is.null(where)) {
    # Normalize variable name in where statement 
    where <- normalizeWhere(where, sep=getWhereSep())

    # Update the where rule (variables names have changed)
    where2      <- updateWhereStr(where, readData$dict_metabnames)
    numallsamps <- nrow(readData$subjdata)
    tmp         <- try(filterCOMETSinput(readData$subjdata,where=where2), silent=TRUE)
    if ("try-error" %in% class(tmp)) {
      print(tmp)
      stop(msg_gmd_8(paste0(where, collapse=" AND ")))
    }
    readData$subjdata <- tmp
    rm(tmp); gc();
    msg <- msg_gmd_9(c(paste0(where, collapse=" AND "),  nrow(readData$subjdata), numallsamps))
    cat(msg)
    if (!nrow(readData$subjdata)) {
      cat(msg_gmd_19()) 
      if (modelspec == getMode_batch()) {
        cat(msg_gmd_10())
        cat(msg_gmd_11())
      }
      stop(msg_gmd_12())  
    }
  }

  gdta <- dplyr::select(readData$subjdata, dplyr::one_of(covlist))

  if(nrow(gdta) < 2) {
    stop(msg_gmd_13())
  }

  # Outcomes and time vars must be numeric
  gdta <- convertVarsToNumeric(gdta, c(rcovs, timecov))

  # If there is one categorical exposure and exposurerefs is NULL, then get the default ref
  if ((length(ccovs) == 1) && !length(exposurerefs)) {
    tmp <- gdta[, ccovs, drop=TRUE]
    if (!is.numeric(tmp)) {
      tmp <- levels(as.factor(tmp))
      if (length(tmp)) exposurerefs <- tmp[1] 
    }
  }


  # Create list for analyses  -------------------------------
  # list for subset data
  # 1: subset data: gdta
  # 2: column variables: ccovs
  # 3: row variables: rcovs
  # 4: adjustment variables: acovs
  #    if (dobug)
  #      prdebug("End of getdata:", dim(gdta))

  ret <- list(
  gdta            = gdta,
  ccovs           = ccovs,
  rcovs           = rcovs,
  acovs           = acovs,
  scovs           = scovs,
  wgtcov          = wgtcov,
  offcov          = offcov,
  timecov         = timecov,
  groupcov        = groupcov,
  dict_metabnames = readData$dict_metabnames,
  modelspec       = modelspec,
  modlabel        = modlabel,
  where           = where,
  allvsall        = allvsall,
  varMap          = varMap,
  options         = options,
  exposurerefs    = exposurerefs
  )

  ret[[runModel.getWarningsListName()]] <- rem.obj
  ret[[getOldCorrModelName()]]          <- runCorrFlag

  ret
}

getCovNames_allMetabs <- function(varString, allmetabs, varMap) {

  varString   <- trimws(tolower(varString))
  allmetabStr <- tolower(getAllMetabsName())
  allFlag     <- grepl(allmetabStr, varString, fixed=TRUE)
  if (allFlag) varString <- gsub(allmetabStr, "", varString, fixed=TRUE)
  vars        <- trimws(as.vector(strsplit(varString, " ")[[1]]))
  if (length(vars)) {
    tmp  <- vars != ""
    vars <- vars[tmp] 
  }
  if (allFlag) vars <- c(vars, allmetabs)
  covs <- runModel.getNewVarName(unique(vars), varMap)

  covs

} # END: getCovNames_allMetabs

getGlobalOptionsFromSheet <- function(opTable, meta=0) {

  # Global options can now also be in the model options part of the table

  if (!meta) {
    modnm   <- getModelOptionsIdCol()
    tmp     <- opTable[, modnm] %in% getGlobalOptionName()
  } else {
    modnm   <- tolower(getMetaOpFileModelTypeCol())
    tmp     <- tolower(opTable[, modnm]) %in% tolower(getMetaGlobalOptionName())
  }
  opTable <- opTable[tmp, , drop=FALSE]
  if (!nrow(opTable)) return(NULL)

  opNameCol <- getOptionNameCol()
  opValCol  <- getOptionValueCol()

  # Remove rows with empty names or values
  tmp       <- !nchar(opTable[, opNameCol]) | !nchar(opTable[, opValCol])
  opTable   <- opTable[!tmp, , drop=FALSE]
  if (!nrow(opTable)) return(NULL)

  # Check the names and values and put them in a list
  ret <- checkGlobalOpsFromCharVecs(opTable[, opNameCol], opTable[, opValCol], meta=meta)

  ret

} # END: getGlobalOptionsFromSheet

getModelFunFromSheet <- function(opTable) {

  col <- getModelFunctionCol()
  vec <- tolower(unique(opTable[, col]))
  tmp <- nchar(vec) > 0
  vec <- vec[tmp]
  n   <- length(vec)
  if (!n) stop(msg_gmd_14())
  if (n > 1) stop(msg_gmd_15())
  
  valid <- c(getValidModelNames(), getOldCorrModelName())
  ret   <- check.string(vec, valid, col)

  ret

} # END: getModelFunFromSheet

getModelOptionsFromSheet <- function(op, opTable, modelFunc) {

  # Function will return complete list of options, since we now allow
  #  a model label to override the global options

  opNameCol <- getOptionNameCol()
  opValCol  <- getOptionValueCol()
  opTable   <- unique(opTable[, c(opNameCol, opValCol), drop=FALSE])
  opnames   <- opTable[, opNameCol, drop=TRUE]
  opvalues  <- opTable[, opValCol, drop=TRUE]

  # Remove ones with no name and no value
  tmp <- (nchar(opnames) < 1) & (nchar(opvalues) < 1)
  if (any(tmp)) {
    opnames  <- opnames[!tmp]
    opvalues <- opvalues[!tmp]
  }
  if (!length(opnames)) return(op)
 
  # Check for missing names
  if (any(nchar(opnames) < 1)) {
    stop(msg_gmd_16())
  }

  # Check for duplicate names
  tmp <- duplicated(opnames)
  if (any(tmp)) {
    str <- paste(opnames[tmp], collapse=", ", sep="")
    msg <- msg_gmd_17(str)
    stop(msg)
  }

  # See if any options are global options. If so, then put them in op and
  #  remove them from the vectors
  tmp <- opnames %in% getValidGlobalOps()$valid
  if (any(tmp)) {
    g.opnames  <- opnames[tmp]
    g.opvalues <- opvalues[tmp]
    opnames    <- opnames[!tmp]
    opvalues   <- opvalues[!tmp]
    tmp        <- checkGlobalOpsFromCharVecs(g.opnames, g.opvalues)
    if ("try-error" %in% class(tmp)) stop(tmp)
    for (nm in g.opnames) op[[nm]] <- tmp[[nm, exact=TRUE]]
  }
  if (!length(opnames)) return(op)

  # Convert model specific options to correct form
  ret <- convertModelOptions(opnames, opvalues, modelFunc)

  # For options that specify variables, make sure they are lower case
  vop <- runModel.getOptionsThatAreVars() 
  if (length(vop) && length(ret)) {
    for (v in vop) {
      var <- ret[[v, exact=TRUE]]
      if (!is.null(var)) ret[[v]] <- tolower(var) 
    }
  }
  op[[getModelOpsName()]] <- ret

  op

} # END: getModelOptionsFromSheet

getAllOptionsForModel <- function(mods, readData, only.modelFunction=0) {

  opTable <- readData[[getMetabDataOpsName(), exact=TRUE]]
  if (!length(opTable)) return(NULL)

  modnm   <- getModelOptionsIdCol()
  modelID <- mods[[modnm,  exact=TRUE]]
  if (length(modelID) != 1) stop("INTERNAL CODING ERROR 1 in getOptionsForModel")  

  # Make sure modelID is in the table
  tmp <- opTable[, modnm] %in% modelID
  if (!any(tmp)) {
    msg <- msg_gmd_18(c(modnm, modelID))
    stop(msg)
  }
  opTable2 <- opTable[tmp, , drop=FALSE]

  # Get the model function
  modelFunc <- getModelFunFromSheet(opTable2)
  if (only.modelFunction) return(modelFunc)

  # If the model function is runCorr, then we don't need to worry about any options
  nm <- getOldCorrModelName()
  if (modelFunc == nm) {
    ret <- list() 
    ret[[nm]] <- 1  # Flag to return signaling runCorr is to be run
    return(ret)
  }

  # Get global options
  op <- getGlobalOptionsFromSheet(opTable)
  if ("try-error" %in% class(op)) stop(op)
  if (is.null(op)) op <- list()

  op$model  <- modelFunc

  # Get model options and include them in op
  op <- getModelOptionsFromSheet(op, opTable2, modelFunc)

  op

} # END: getAllOptionsForModel

