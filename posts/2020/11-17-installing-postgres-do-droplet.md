==title==
 Installing Postgres on Digital Ocean Droplet for a Phoenix Application
==author==
 Andrew Barr
==description==
 I recently built a proof of concept application using Elixir with Phoenix and deployed it to Digital Ocean.
==tags==
 Elixr
==body==

## Installing Postgres

This post assumes you have a Digital Ocean Droplet using Ubuntu and setup for an Elixir Application using Phoenix. To get started open a `ssh` session to your Droplet and run the following commands. If you have not setup your server check out this [Post](https://andrewbarr.io/posts/website-and-blog-5-dolllars-a-month-p1).

```
$ sudo apt update
$ sudo apt install postgresql postgresql-contrib
```

By default the installation process will setup a user called `postgres` so you can test teh installion by changing user accounts and opening the Postgres prompt:

```
$ sudo -i -u postgres
$ psql
```

If your installation is successful you should now be able to list all of the databases:

```
postgres=# \l
```

Once you are sure everything is working type `\q` to exit the prompt and then `exit` to go back to your user account. Back in your own account we now want to create a user that can connect to our applicatiosn database:

```
$ sudo -u postgres createuser --interactive
```

It will prompt you for a user name and role. At this stage select yes for superuser. You can create different roles later and modify the account as required. Postgres requires that each user has a database of the same name so at the cmd line type:

```
$ sudo -u postgres createdb user-name-you-chose
```
No create a local user so that you can use the ident based authentication used by Ubuntu:

```
$ sudo adduser user-name-you-chose
```

Now you can open a Postgres prompt using your new user:

```
$ sudo -u user-name-you-chose psql
```

Test the account by listing the databases, then create a database for you Phoenix application:

```
user-name-you-chose=# \l
user-name-you-chose=# createdb application_name_prod;
user-name-you-chose=# \q
```

Back at the prompt set a password for `user-name-you-chose` so the application can connect securely:

```
$ sudo -u postgres psql
postgres=# \password user-name-you-chose # Follow prompts to set password
postgres=# \q
```

## Modify Phoenix Aplication

I am using Github Actions to deploy my Phoenix application and added a Secret to the Github repo called `PG_PASS`. Alternatively you may wish to use `prod_secrets.exs` on the Droplet. If you are using `ENV_VARS` modify your `prod.exs` to include:

```
config :my_app, MyApp.Repo,
  username: "user-name-you-chose",
  password: System.get_env("PG_PASS"), # If using prod_secrets.exs you can add the password here
  database: "my_app_prod",
  hostname: "127.0.0.1",
  pool_size: 10
```

You can now create a `PROD` release and test your database connection. I will write a post shortly to show how I am using Github Actions to deploy my applications.




 



<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>