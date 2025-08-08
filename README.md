Textpattern CMS project template
=====

Work in progress. Only meant for local development and testing usage. Contains basic frontnend build
environment built around webpack and LESS, and few base Textpattern plugins such as rah_autoload,
which allow autoloading and extending the backend with Composer packages and libraries.

Services
-----

Once installed, different local services can be found at:

* Texpattern CMS: [http://projectname.test/](http://projectname.test/)
* Mailhog: [http://mailhog.projectname.test/](http://mailhog.projectname.test/)
* phpmyadmin: [http://phpmyadmin.projectname.test/](http://phpmyadmin.projectname.test/)

Install
-----

To set up the project, run:

```shell
$ make install
```

After that, run the following and add the output to your hosts file:

```shell
$ make hosts
```

Once the host mapping has been added, the hostname can be used to access the services and the
Textpattern site. The project's hostname and other configuration can be changed
by modifying `.env.template` for the project before running `make install`. The changes
can be committed to the project's repository.

Usage
-----

To start installed project, run:

```shell
$ make start
```

Development
-----

For list of available commands, run:

```shell
$ make help
```
