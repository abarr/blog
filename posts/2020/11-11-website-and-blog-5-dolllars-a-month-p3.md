==title==
 A Website and a Blog for $5/mo - Part 3
==author==
 Andrew Barr
==description==
 Deploying a second Phoenix application to a Digital Ocean Droplet using Nginx to route requests. 
==tags==
 elixir
==body==


This is the third part of a series focussing on setting up more than one Phoenix Application on a single Digital Ocean Droplet (<span class="text-indigo-600">[Part 1 can be found here](https://andrewbarr.io/posts/website-and-blog-5-dolllars-a-month-p1)</span> and <span class="text-indigo-600">[Part 2 here](https://andrewbarr.io/posts/website-and-blog-5-dolllars-a-month-p2)</span>).

## A Second Phoenix Application 

Follow the same process to create a second Phoenix application described in <span class="text-indigo-600">[Part 2](https://andrewbarr.io/posts/website-and-blog-5-dolllars-a-month-p2)</span>. 

## Git 

Create your local git repo and add the `github` remote.

```
$ git init
$ git remote add origin git@github.com:your_user_name/your_project_name.git
$ git add .
$ git commit -m "initial commit"
$ git push --set-upstream origin master
```

## Deployment

Our first deployment will be manual (In a future post I will show you how I automated it). Start by connecting to your Droplet using `ssh`. We need to add an `ssh-key` to `github` so we can pull the repo to our server. Just like before run `ssh-keygen` (ensuring the new key is created in the `.ssh/` directory). I used all of the default settings, and then used the `more` cmd to copy the public key (Make sure it is the `.pub` file). 

Once you have the public key go to your `github` account and navigate to the deploy keys sections Settings -> Deploy Keys. Create a new deploy key (naming it something meaningful) and paste in the public key from the server. Now that you have the deploy key setup, grab the clone url from the Clone or Download menu. Go back to your `ssh` session with the Droplet and clone your repo on the server.

```
$ git clone git@github.com:your-account/your-project.git
```

Once the project has been cloned run through the local setup.

```
$ cd project_name
$ mix deps.get
$ cd assets
$ npm install
```

Because we are going to be creating a `PROD` release we need to change our configuration. Go back to your `github` account and navigate to Settings -> Secrets. Create a new secret called `KEY_BASE` and past in a key generated at in your terminal using `mix phx.gen.secret 64`. Then create a new secret called `SIGNING_SALT` and paste in the key generated using `mix phx.gen.secret 32`. 

Go back to your local editor and open `/config/prod.exs` and make the following changes. Make sure you change the default `port` to something other than `4000` as our existing application is using it. The change below assumes you have a different domain for your second site and have added `dns` records to point to your server.

```
use Mix.Config

config :your_app, YourAppWeb.Endpoint,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4001"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: "your-domain.com", port: 80],
  check_origin: [
    "https://your-domain.com",
    "https://www.your-domain.com"
  ],
  secret_key_base: System.get_env("KEY_BASE"),
  live_view: [signing_salt: System.get_env("SIGNING_SALT")]

# Do not print debug messages in production
config :logger, level: :info
```

Commit your changes from your local machine to `github`.

```
$ git add .
$ git commit -m "Modified PROD config"
$ git push
```

Now go back to your `ssh` session on the Droplet and run `git pull` from the project directory. Your project will now be up to date on the server. Before we build our release we are going to setup `Nginx`. 

```
$ cd /var/www
$ sudo mkdir -p your-website-name/html
$ sudo chown -R $USER:$USER your-website-name/html
$ sudo chmod -R 755 your-website-name
```

To serve your new application we need to create a setting file, you can copy and modify the default settings by running:

```
$ sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/your-website-name
```

Open the settings file for your project using `$ sudo vim /etc/nginx/sites-available/your-website-name`, add the following section directly above the sever config (Assuming you have used `4001` as the `port`).

```
upstream your-website-name{
	server 127.0.0.1:4001;
}

server {

    ...
        
    listen 80;
    listen [::]:80;
    ...

    ...
    
    root /var/www/your-website-name/html;
    ...

    ...
    
    server_name your-domain www.your-domain;
    ...
}
```

Then go down to the `location` section and change it to

```
location / {
	allow all;

	proxy_http_version 1.1;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_set_header X-Cluster-Client-Ip $remote_addr;

	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection "upgrade";

	proxy_pass http://your-website-name; # Defined above
}
```
Finally setup the symbolic link:

```
$ sudo ln -s /etc/nginx/sites-available/your-website-name /etc/nginx/sites-enabled
```

Save and test the config using `sudo nginx -t` and if OK restart with `sudo systemctl restart nginx`. Now we can build and start our Phoenix application and test our server. Go to the project directory and run

```
$ npm run deploy --prefix ./assets
$ mix phx.digest
$ MIX_ENV=prod mix compile
$ MIX_ENV=prod mix release 
$ _build/prod/rel/your_project/bin/your_project start
```

You should now be able to go to your domain and see your Phoeinx application. You can stop your application by using 

```
$ _build/prod/rel/your_project/bin/your_project stop
``` 

If you want to run your application and exit the Droplet you can use 

```
$ _build/prod/rel/your_project/bin/your_project daemon
``` 
You can see all the commands available using 

```
$ _build/prod/rel/your_project/bin/your_project
```

You should now have two seperate sites working on a single Digital Ocean Droplet.

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>