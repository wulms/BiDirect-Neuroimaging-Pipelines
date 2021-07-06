%-----------------------------------------------------------------------
% Job saved on 17-Oct-2019 14:17:14 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.dir = {'/media/niklas/My Book/Bidirect_Dicom/BIDS/base_protocol'};
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.filter = 'T1.nii.gz';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPListRec';
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (T1.nii.gz)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.action.copyto = {'/media/niklas/My Book/BIDS/derivatives/SPM/anat/unzipped_T1w_files'};
