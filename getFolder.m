function [pathname] = getFolder
% Pick a directory with the Java widgets instead of uigetdir

import javax.swing.JFileChooser;


start_path = pwd;


jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);

jchooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

jchooser.setDialogTitle('choose DICOM folder');


status = jchooser.showOpenDialog([]);

if status == JFileChooser.APPROVE_OPTION
    jFile = jchooser.getSelectedFile();
    pathname = char(jFile.getPath());
elseif status == JFileChooser.CANCEL_OPTION
    pathname = [];
else
    error('Error occured while picking file.');
end