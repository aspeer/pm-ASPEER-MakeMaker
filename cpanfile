requires 'File::Temp';
requires 'Software::LicenseUtils';
requires 'Tie::File';
requires 'perl', '5.006';

on configure => sub {
    requires 'perl', '5.038002';
    requires 'version';
    suggests 'ExtUtils::Markdown::Pod';
};

on test => sub {
    requires 'File::Temp';
    requires 'Test::More';
};
