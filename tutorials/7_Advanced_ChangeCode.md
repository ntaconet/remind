---
output:
  html_document: default
  pdf_document: default
---
Advanced: Change REMIND GAMS Code
================
Florian Humpenöder (<humpenoeder@pik-potsdam.de>), Lavinia Baumstark (<baumstark@pik-potsdam.de>)


Technical Structure
=====================
The REMIND-code is structured in a modular way. The technical structure looks as follows: at the top level you find the folders `config`, `core`, `modules`, and `scripts`. The overall structure is built in the file `main.gms`. All settings and configuration information are given in the `config` folder. The `core` folder contains all files that are part of the core of the REMIND model. For each module there exists a sub-folder in the `modules` folder. Helpful scripts for e.g. starting a run or analysing results you find in the `scripts` folder.

In the `main.gms` file the technical structure of REMIND can be found. First, the `*.gms` files from the core folder are included and afterward the `*.gms` files from the activated module realization, beginning with the one with the smallest module-number. The technical structure of REMIND looks as follows:

```
SETS

DECLARATION    ---> of equations, variables, parameters, and scalars

DATAINPUT

EQUATIONS

PRELOOP        ---> initial calibration of e.g. macroeconomic model

LOOP
        ---> read gdx
----------------------------------------------- BEGIN OF NEGISH/NASH ITERATION LOOP -----
      * BOUNDS
      * PRESOLVE
      * SOLVE     ---> solve statement in module 80_optimization
      * POSTSOLVE
      
        ---> write gdx
----------------------------------------------- END OF NEGISHI/NASH ITERATATION LOOP ----

OUTPUT
```

In general, the `.gms`-files in each module realization can be the same as in the core. For each module it has to be clearly defined what kind of interfaces it has with the core part of the model.

Coding Etiquette
==================
The REMIND GAMS code folllows a coding etiquette.

#### Naming conventions:
Please put effort into choosing intelligible names.

* Don't just enumerate existing names: `budget1`/`budget2`, `tradebal1`/`tradebal2` will cause everyone for the next years much more frustration than if you choose names like `emi_budget_G8`/`emi_budget_Mud`, `tradebal_res`/`tradebal_perm`/`tradebal_good`.
* Explain the abbreviation you designed in the descriptive text (the part with the `" "` behind each parameter/variable/equation declaration). `directteinv` is easier to memorize if you know it means "Direct technology investment".
* Within REMIND files: use Capitalization to improve readability. `XpPerm` is more easily translated into "Export of Permits" than `xpperm`, the first part of the name (after the prefix) should describe the type of parameter/variable (e.g. `sh` for share, `cap` for capacity, `prod` for production, `dem` for demand, `cost` for costs)

#### Prefixes:
Use the following *prefixes*:

* `q_` to designate equations,
* `v_` to designate variables,
* `s_` to designate scalars,
* `f_` to designate file parameters (parameters that contain unaltered data read in from input files),
* `o_` to designate output parameters (parameters that do not affect the optimization, but are affected by it),
* `p_` to designate other parameters (parameters that were derived from "f_" parameters or defined in code),
* `c_` to designate config switches (parameters that enable different configuration choices),
* `s_FIRSTUNIT_2_SECONDUNIT` to designate a scalar used to convert from the FIRSTUNIT to the SECONDUNIT 
                             through multiplication, e.g. `s_GWh_2_EJ`.

These prefixes are extended sometimes by a second letter:

* `?m_` to designate objects used in the core and in at least one module.
* `?00_` to designate objects used in a single module, exclusively, with the 2-digit number corresponding 
         to the module number.

Sets are treated differently: instead of a prefix, sets exclusively used within a module get that module's 
number added as a suffix. If the set is used in more than one module no suffix is given. 
 
The units (e.g., TWa, EJ, GtC, GtCO2, ...) of variables and parameters are documented in the declaration files.

#### Commenting:

* Comment all parts of the code generously
* For all equations, it should become clear from the comments what part of the equation is supposed to do what
* Variables and parameters should be declared along with a descriptive text (use `" "` for descriptive text to avoid compilation errors)
* Use three asterisks `***` for comments or `*'` if the comment should show up in the documentation of REMIND 
* Never use 4 asterisks (reserved for GAMS error messages)
* Don't use the string `infes` in comments
* Don't use `$+number` combinations, e.g., `$20` (this interferes with GAMS error codes).
* Indicate the end of a file by inserting `*** EOF filename.inc ***` 

#### Sets

* don't use set element names with three capital letters (like `ETS` or `ESR`), otherwise the maglcass R library might interpret this as a region name when reading in GDX data


#### Equations:
The general idea is not to write code and equations as short as possible, but to write them in a way they can be read and understood as fast as possible. To that end:

* Write the mathematical operator (`*`, `/`, `+`, `-`) at the beginning of a line, not the end of the last line
* Leave a space before and after `+` and `-` operators and equation signs (`=g=`, `=l=`, `=e=`)
* Leave a space behind the comma of a sum (not behind the commas in set element calling)
* Use indentations to make the structure more readable
* Use full quotes (`"feel"`) instead of single quotes (`'feel'`) when specifying individual elements of a set (this makes automatic replacement via sed easier)
* Put the equation sign (`=g=`, `=l=`, `=e=`) in a single line without anything else


#### Other general rules:
* Decompose large model equations into several small equations to enhance readability and model diagnostics
* Don't use hard-coded numbers in the equations part of the model
* Parameters should not be overwritten in the initialization part of the models. Use if-statements instead. Notable exceptions include parameters that are part a loop iteration, e.g. Negishi weights.
* Have your work double-checked! To avoid bugs and problems: If you make major changes to your code, ask an experienced colleague to review the changes before they are pushed to the git main repository.
* Use sets and subsets to avoid redundant formulation of code (e.g., for technology groups)
* If big data tables are read in exclude them from the `.lst`-file (by using `$offlisting` and `$onlisting`), nevertheless display the parameter afterwards for an easier debugging later
* When declaring a parameter/variable/equation always add the sets it is declared for, e.g. `parameter test(x,y);` instead of `parameter test;`
* do not set variables for all set entries to zero (if not necessary), as this will blow up memory requirements.

How to make a new module or realization in REMIND
========================================================

If you want to create a **new module** in REMIND first think about the interfaces between the core code and your new module. This helps you to design your module. 

For creating a new module you can use the function `module.skeleton` from the R package `gms`. Start R and set the working directory to the REMIND folder (e.g. `setwd("~/work/remindmodel")`). 

``` r
gms::module.skeleton(100, "bla", c("on", "off"))
```

It creates all folders and gams files for your new module `100_bla` with the realizations "on" and "off". You can find more information about the function `module_skeleton` in its documentation.

For creating a **new realization** of an existing module you can also use the R function `gms::module_skeleton`. Start R and set the working directory to the REMIND folder (e.g. `setwd("~/work/remindmodel")`).

``` r
gms::module.skeleton(100, "bla", c("on", "off", "new"))
```
It creates all additional gams files for your new realization "new" of the existing module `100_bla`. You can find more information about the function `module_skeleton` in its documentation.

After you have created all of your new files and lines for the new module or realization you have to add the description of this new feature in both the `main.gms` and in the `default.cfg` by hand.

Compiling
=============

Using the
``` 
cfg$action
```
option in `config/default.cfg` you can choose whether you want to start a run or simply check if your code compiles. By setting the option to simply `"c"` (for compile), your code will only be tested and no SLURM job will start on the cluster (helps when the cluster is full). Default value for the option is `"ce"` (for compile and execute).

You can also compile the file `main.gms` directly by running the command
```bash
gams main.gms -a=c -errmsg=1
```
or (only works on the PIK cluster, gives you highlighting of syntax errors)
```bash
gamscompile main.gms
```
This has the additional advantage of telling you in which exact file a compilation error occurred and running really fast. However, this will not take into consideration the changes you made to [`config/default.cfg`](../config/default.cfg). So if you want to test changes you made to a non-standard module realization, be sure to update the settings in [`main.gms`](../main.gms) by either editing it manually or running `./start.R -0` which resets `main.gms` to the entries of `config/default.cfg` (to get the settings of a `scenario_config*.csv`, start a single run with `start.R -i` and wait until `main.gms` is updated, then kill the run).
