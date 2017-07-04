% MUTTRULEZ(1) | Version 0
%
% 2017-07-04

Email rule engine for mutt users. Use from cron to run rules automatically.
Supports IMAP for reading and whatever mutt uses for sending.
Takes IMAP config from `~/.muttrc`

# SYNOPSYS

    muttrulez [OPTIONS]
    muttrulez [OPTIONS] <config>

# OPTIONS

    -u	Run unit-tests, as defined at the beginning of the muttrulez script
    -h	Print help text

# CONFIGURATION

Reads rule configuration from `~/.muttrulez` by default, or from config file
supplied on command line. The config format is YAML.

The config contains a list of rules, each with 3 mandatory fields:
`name`, `search`, `steps`.

## EXAMPLE CONFIG FILE

Look for emails from foo@bar.hu with PDF attachments, save them in `~/Downloads`,
if PDF contains text 'Eggs', forward it to `baz@spam.com` with default email text
body, flag such emails with `$Forwarded`.

Archive emails older than 6 months to folder 'Old'.

The example illustrates diverse YAML styles, as accepted by `YAML::XS`.

    ---
    - name: Forward PDF
      search:
        FROM: foo@bar.hu
      steps:
      - { action: accept, type: attachment, mime: application/pdf, save: ~/Downloads }
      - { action: accept, type: pipegrep, cmd: pdftotext _ -, regex: Eggs }
      - action: accept
        type: email
        to: baz@spam.com
        attach: _
        text: |
          Hi Baz,
          PDF with Eggs forwarded.
          Yours Truly, Me
      - { type: add_flags, flag: $Forwarded }
    - name: Archive
      search:
        BEFORE: 6m
      steps:
      - { action: accept, type: move, folder: old }

# SEARCH

The search field contains a hash with IMAP compliant fields as keys.
See RFC3501 http://www.ietf.org/rfc/rfc3501.txt section 6.4.4 for search keys.

# STEPS

Each rule has a flat list of steps, which process all your conditions and actions.

Each step returns a list of values internally, depending on the type.

Each step in turn takes the return list of the previous step,
which you can refer to as the `_` symbol.

The `action` field of each step determines whether to continue processing
further steps:

* accept: continue to next step if step returned list, otherwise stop rule
* reject: stop rule if step returned list, otherwise continue to next step, pass 1

Each step has a manadatory `type` field, plus zero or more type-dependent
extra fields.

# STEP TYPES

## flag

Continue or abort on certain MIME flags found on email.

Fields:

* flag: IMAP flag you're looking for

Returns: the specified flag if found on email, or nothing

## attachment

Searches for and optionally saves attachments of certain types.

Fields:

* mime: MIME type of attachment you're looking for
* save: folder to save file permanently, optional

Returns: filenames of matching attachments

## pipegrep

Run a program for each element in input, search regex in its STDOUT

Fields:

* cmd: command line to run, refer to input element with `_`
* regex: pattern to search for in command's STDOUT

Returns: input elements for which pattern was found in command's STDOUT

## email

Send email using mutt.

Fields:

* to: email address
* attach: filename or `_` to attach input list of filees
* subject: optional, processed email's is used when missing
* text: text of email body

Returns: 1 if mutt sends email successfully

## add_flags

Set flags for emails

Fields:

* flag: flag name to set

Returns: 1 on success

## del_flags

Delete flags for emails

Fields:

* flag: flag name to set

Returns: 1 on success

## copy

Copy email to IMAP folder

Fields:

* folder: IMAP folder name

Returns: 1 on success

## move

Move email to IMAP folder

Fields:

* folder: IMAP folder name

Returns: 1 on success

## delete

Delete email

Returns: 1 on success
