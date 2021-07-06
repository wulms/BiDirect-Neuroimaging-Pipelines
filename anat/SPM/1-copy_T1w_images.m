% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/home/niklas/Dropbox/White_Matter_Project/WML_Paper_Code/neuroimaging-processing/anat/SPM/1-copy_T1w_images_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
