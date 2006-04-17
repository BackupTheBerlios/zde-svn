#ifndef ZIMWM_MODULE_H
#define ZIMWM_MODULE_H

/**
  All modules should define AT LEAST these public functions.
  */

/** 
  Module should initialize any variables and data structures here, open files, etc.
  Return 0 if successful, anything positive if recoverable error, 
  anything negative if unrecoverable error. 
 */
int zimwm_module_init(void);

/**
  Module should free and variables and data structures here, close files, etc.
  */
void zimwm_module_quit(void);

/**
  Returns a string containg the version of the module, i.e. "Systray 0.0.1-pre1"
  */
char *zimwm_module_version(void);

/**
  Returns a string containing an "About" string for the module.
  */
char *zimwm_module_about(void);
#endif
