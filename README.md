Textpattern CMS project template
=====

Work in progress. Only meant for local development and testing usage. Contains basic frontnend build
environment built around webpack and LESS, and few base Textpattern plugins such as rah_autoload,
which allow autoloading and extending the backend with Composer packages and libraries.

Services
-----

Once installed, different local services can be found at:

* Texpattern CMS: [https://projectname.test/](https://projectname.test/)
* Mailhog: [https://mailhog.projectname.test/](https://mailhog.projectname.test/)
* phpmyadmin: [https://phpmyadmin.projectname.test/](https://phpmyadmin.projectname.test/)

Install
-----

To set up the project, run:

```shell
$ make install
```

If you want, the project's configuration can be customized, before running the setup, through a `.env` file. If the
file does not exist yet in the project root directory, you can initialize one by running:

```shell
$ make create-env
```

### Set up hosts mapping

After setting up, run the following and add the printed mapping output to your `/etc/hosts` file:

```shell
$ make hosts
```

This will allow you to access the project by the domain defined in the project's `.env` file.

### Set up self-signed root certificate

The project generates self-signed certificates during the setup to offer HTTPS for the local Saleor installation. To
make sure the self-signed works in your OS and web browser, add the `certificates/root-ca.pem` file to your Browser's
or OS's trusted root certificates.

Development
-----

To start installed project, run:

```shell
$ make start
```

To stop:

```shell
$ make stop
```

To uninstall:

```shell
$ make clean
```

For list of all available commands, run:

```shell
$ make help
```
