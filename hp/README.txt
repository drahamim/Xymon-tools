OVERVIEW

This repository provides access to various software products for your use.
Multiple access modes are offered to make it as convenient as possible to use
and integrate with your processes. Please refer to the Getting Started
information to understand how to configure and use this service most
effectively.

The artifacts available in the repository are covered by their respective
agreements and licensing terms. Currently the offerings are primarily Linux
ones, but this may be expanded over time, both with regard to products and
to distributions (or other operating systems), so check back often.

Getting Started

As this repository contains multiple software products and system targets,
it is designed for many types of access modes. This guide will help you get
the most from the repository.

Essentially there are three major use cases for accessing this repository.

A. Ad-hoc or interactive downloads
    At any time, you can access the repository via a browser or command line
utility (see ./downloads). If you need only a single component, this may be
the preferred way to obtain it. Of course, this means:

        * you will need to carefully pick the applicable component for your use,
        * you will have to manually install the component after downloading, and
        * you will need to deal with any install-time dependencies or further
          updates manually. 

B. Mirroring
    At your discretion, you may elect to mirror any or all of the repository.
This may be preferred due to local networking restrictions or simply to improve
network performance for any of your systems which can then install or update
from your mirrored copy (see Direct access use case section and related
F A Q entries for utilizing your mirror).

    Note : Please follow good mirroring and network usage practices, and use
           efficient tools like rsync or mirror to only transfer what has been
           updated.

    For example you can mirror the contents of the entire repository with the
following command:

        rsync -av downloads.linux.hp.com::SDR <MyLocalMirorrPrefix>

C. Direct access install or update
    For those systems which can directly access the repository, you can set
them up to query the product (or multiple ones) of your choice. Once configured,
these system can track any released updates to those products. To configure
this type of access, follow the listed steps: 

       1.  Obtain the "./downloads/bootstrap.sh" script and place it on the
           system you wish to access the repository from.
              * Feel free to review the content of this script to satisfy any
                security or invocation concerns. If in doubt, feel free to run
                it as a normal (non-root) user, or in the preview (-n) mode.
              * Make note of the product bundle name you care to install, as
                shown on the ./downloads page.
              * When ready, invoke the script via:

                    sh ./bootstrap.sh <ProductBundleName>

                as any user with the appropriate options, or refer to the
                usage information via

                    sh ./bootstrap.sh -h

                If all the prerequisite checks pass, this will deliver the
                relevant repository access configuration for your specific
                distribution, version, architecture, and product combination.
                The resulting configuration can be replicated to any number
                of similar systems, if you wish.
              * By default, the configuration will point to the currently
                released set for a given software product. As newer versions
                become available, your system can track these newer releases
                (see F A Q entries for ways to only track a particular release)
       2. At this point, you may use any of the default system tools (like
apt-get, yum, or zypper) to query, install, and remove packages from your
system based on this repository's contents. As you might expect, this class
of tools will download the requested component meta-data from repository
indices and calculates the required actions for installation or removal.
       3. When you install packages, this repository will work in concert with
any of your previously configured repositories to resolve dependencies and
install in the order dictated by the meta-data indices.

F A Q

Frequently Asked (and Answered) Questions

The repository does not contain <InsertTypeOfDownload> or something for my
particular distribution, version, architecture combination. Why not ?
    There could be a multitude of reasons like:

        * well behaved, binary packages are not yet available
        * the source (or SRPMS) are not being published
        * either the testing has not been completed, or no interest has
          been shown in the platform to date

I need to use a proxy to access the repository. How do I set that up ?
    Consult the manual pages of the tool you are using to access the
    repository (ie. apt-get, yum, zypper) to setup the correct proxy
    configuration. Of course, you are also welcome to mirror the repository
    to a local host.

I have mirrored the repository to my local network. How do I use this from
my system?
    You can still utilize the bootstrap.sh script, however, you will want to
    possibly use one or more of the "-m", "-w", or "-u" command line options to
    specify your mirror's setup.

I noticed that some packages or indices are signed. How can I verify the signatures of the packages in the repository?
    In the top level of the Product's directory, you should find a file named "GPG-KEY-<ProductName>". As root,

        * for RPM-based distributions run:

              rpm --import URLtoGPG-KEYFile

          and verify via

              rpm -qa gpg-pubkey*

        * for DEB-based distributions run:

              wget URLtoGPG-KEYFile; -O - | apt-key add -

          and verify via

              apt-key list

        * then look for an entry containing the string "2689b887" or "2689B887" and associated with the Hewlett-Packard Company.

I do not want to continually track the "current" released set, but am happy
with a particular release of a given product. How do I configure that ?
    In the configuration that was delivered by the "bootstrap.sh" script,
    look for the "current" element of the path, and replace it with the
    version you prefer to remain at or rerun the "bootstrap.sh" script with
    the desired "-R" argument and value. 
