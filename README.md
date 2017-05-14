% MUTTRULEZ(1) | Version 0
%
% 2017-05-14

Email rule engine for mutt users. Use from cron to run rules automatically.
Supports IMAP for reading and whatever mutt uses for sending.
Takes IMAP config from ~/.muttrc

# SYNOPSYS

`muttrulez`

# CONFIGURATION

Place your rules in ~/.muttrulez in YAML format.

The config contains a list of rules, each with 3 mandatory fields:
name, search, steps.

## EXAMPLE CONFIG FILE

    ---
    - name: Forward PDF
      search:
        FROM: foo@bar.hu
      steps:
      - action: accept
        type: attachment
        mime: application/pdf
        save: 1
      - action: accept
        type: pipegrep
        cmd: pdftotext _ -
        regex: Eggs
      - action: accept
        type: email
        to: baz@spam.com
        attach: _
        text: |
          Hi Baz,
          PDF with Eggs forwarded.
          Yours Truly, Me
      - type: add_flags
        flag: $Forwarded

# SEARCH

The search field contains a hash with IMAP compliant fields as keys.

# STEPS

There is a flat list of steps, which process all your conditions and actions.

Each step returns a list of values internally, depending on the type.

Each steps in turn takes the return list of the previous step,
which you can refer to as the `_` symbol.

The `action` field of each step determines whether to continue processing
further steps:

* accept, rule returned list: continue next step, pass list
* accept, rule returned nothing: stop rule on email
* reject, rule returned list: stop rule on email
* reject, rule returned nothing: continue next step, pass 1

# CURRENTLY SUPPORTED STEP TYPES

## flag

Continue or abort on certain MIME flags found on email.

Fields:

* flag: IMAP flag you're looking for

Returns: the specified flag if found on email, or nothing

## attachment

Searches for and optionally saves attachments of certain types.

Fields:

* mime: MIME type of attachment you're looking for
* save: 1 to save file temorarily for next steps

Returns: filenames of matching attachments

## pipegrep

Run a program for each element in input, search regex in its STDOUT.

Fields:

* cmd: command line to run, refer to input element with `_`
* regex: pattern to search for in command's STDOUT

Returns: input elements for with pattern was found in commands STDOUT.

## email

Send email using mutt.

Fields:

* to: email address
* attach: filename or `_` to attach input list of filees
* subject: optional, processed email's is used when missing
* text: text of email body

Returns: 1 if mutt sends email successfully.

## add_flags

Set flags for emails:

Fields:

* flag: flag name to set

Returns: (1, ...) on success

## del_flags

Delete flags for emails:

Fields:

* flag: flag name to set

Returns: (1, ...) on success
