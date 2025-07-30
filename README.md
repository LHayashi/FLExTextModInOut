This is a repo for some ongoing work to create richer FLExText export including audio offsets and meta-data from the Notebook records that own Interlinear Texts.

# Flow chart of processes
https://www.canva.com/design/DAGTm3neQH0/U3QD6c9UA23iSqk1PVurig/view?utm_content=DAGTm3neQH0&utm_campaign=designshare&utm_medium=link&utm_source=editor

# FLExTextModInOut
Transforms for adding begin and end offsets as a custom field "InOut" in FieldWorks/FLEx interlinear
Both of these files need to be copied to C:\Program Files\SIL\FieldWorks 9\Language Explorer\Export Templates\Interlinear.
Refer to https://docs.google.com/document/d/1siYTatJtr95aSVpSzOK_pngChliIOFOSaNTYuK_3haI/edit?usp=sharing for detailed procedures.

# FLExTextwithMetaNotebook.xsl
Gathers the data that it is in the containing FieldWorks Notebook record associated with an Interlinear Text. Early stage development.
Merges Notebook meta-data with the FLExText file.

