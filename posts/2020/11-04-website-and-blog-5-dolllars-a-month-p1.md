==title==
 A Website and a Blog for $5/mo - Part 1
==author==
 Andrew Barr
==description==
 This post describes setting up a Digital Ocean Dropletusing Nginx and LetsEncrypt and preparing it to host a Phoenix Application. 
==tags==
 elixir
==body==


I am on a mission to once again work as a developer (Ideally using Elixir) so set about converting my Wordpress website and blog to Phoenix Applications. I had read [Dashbit's](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) post about precompiling their posts and loading them into memory. I loved the idea of not relying on a database and set about converting my existing sites (There was not much to post as I am only just starting). I cancelled my Wordpress account and headed over to Digital Ocean as they had a $100 credit promotion for new accounts.

## Digital Ocean

Once I had signed up I went ahead and created a new project. After clicking on the Project in the menu I created a new Droplet. I chose the default Ubuntu operating system and scrolled all the way to the left to choose the $5/mo option. I nominated the closest region to me (I am in Australia) and then chose SSH for authentication.

To setup the SSH key open a terminal window (I am on a Mac) and navigate to your ssh folder and type `ssh-keygen`. You will be asked to nominate a file name, I chose `id_rsa_do`.

```
$ cd ~/.ssh
$ ssh-keygen
```

Press enter twice to skip past the passphrase option. Grab the contents of the public key using the `more` command.

```
$ more id_rsa_do.pub
```

Copy the key and paste it into the form after clicking the `new SSH Key` button on the Digital Ocean webpage. After you create the Droplet you will be able to copy the `ip address`. Once you have it open your `.ssh/config` file in the editor of your choice (I use `vim`). Create a `Host` block.

```
Host your-droplet-ip
	HostName your-droplet-ip
	IdentityFile /Users/path/to/.ssh/id_rsa_do
	
```

Now you can open your terminal and log into your new Droplet using `SSH`.

```
$ ssh root@your-Droplet-ip
```

It is always good practice to create a new `user` to control your Droplet rather than using the `root` account. At the command line type the following command and create a new password when prompted:

```
$ adduser your-user-name
```

After creating the new `user` modify the account to give it the privlages you need. Following that copy over the .ssh directory to your new `user` account so you can login directly to the account using the `ssh key` from above.


```
$ usermod -aG sudo your-user-name
$ rsync --archive --chown=your-user-name:your-user-name ~/.ssh /home/your-user-name
```


 You can now close the ssh connection and test your new account by loging back in:

```
$ ssh your-user-name@your-Droplet-ip
```

I have a domain name (andrewbarr.io) so I changed the DNS records so there was an A record for andrewbarr.io and *.andrewbarr.io pointing to my Droplets ip address. This allowed me to modify the `.ssh/config` file:

```
Host your-domain
	HostName your-domain
	IdentityFile /Users/path/to/.ssh/id_rsa_do
	
```

Now when you login to your Droplet you can use `$ ssh your-user-name@your-domain`


## Setting up Erlang, Elixir and Node

At the command line of your Droplet run the following commands. You can find the <span class="text-indigo-600">[Erlang installation instructions](https://www.erlang-solutions.com/resources/download.html)</span> under the <span class="font-semibold">Installation Using Repository</span>
 heading.

```
$ sudo apt-get update
$ sudo apt-get install -y build-essential
$ wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb 
$ sudo dpkg -i erlang-solutions_2.0_all.deb
$ sudo apt-get update
$ sudo apt-get install erlang
$ sudo apt-get install elixir
```

Check that everything has installed by running `$ elixir -v`, you should see the Erlang and Elixir versions that have been installed. If everything is looking good it's time to install `Nodejs`.

```
$ sudo apt install nodejs
$ sudo apt install npm
$ sudo apt-get update
```

Check that everything has installed by running `$ node -v` and `npm -v`. We are now ready to setup a server so we can host more than one website on the server.


## Nginx and LetsEncrypt

Start by installing `Nginx` and modifying the firewall settings.

```
$ sudo apt-get install nginx
$ sudo ufw allow OpenSSH
$ sudo ufw allow http
$ sudo ufw allow https
$ sudo ufw enable
```

After installing you can check the status of `Nginx` by running `$ systemctl status nginx`, you should see that the service is enabled and running. You can now go to your domain in the browser and it will load the `Nginx` welcome page. Next we want to create a location to host our own website. At the command line:

```
$ cd /var/www
$ sudo mkdir -p your-website-name/html
$ sudo chown -R $USER:$USER your-website-name/html
$ sudo chmod -R 755 your-website-name
```

To test the config navigate to the `html` directory and create an `html` file.

```
$ cd your-website-name/html
$ sudo vim index.html
```

Save whatever markup you want and save the file.

```
<html>
	<h1>HELLO</h1>
</html>
```

To serve your new page we need to create a setting file, you can copy and modify the default settings by running:

```
$ sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/your-website-name
```

Now open the settings file in an editor `$ sudo vim /etc/nginx/sites-available/your-website-name` and make the following changes.

```
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


```

After saving create a symbolic link from `Nginx` sites-available to the sites-enabled

```
$ sudo ln -s /etc/nginx/sites-available/your-website-name /etc/nginx/sites-enabled
```

You can now test your `Nginx` configuration by typing `$ sudo nginx -t`, upi should see a message saying it is OK. You can now restart `Nginx` with `$ sudo systemctl restart nginx`. Now you can navigate to your domain in the browser and you should see your custom html craeted above.


Now we want to make sure our traffic is secure so we will install `LetsEncrypt`. At the command line type the following commands, ensuring you use a valid email address to get expiration warnings.

```
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt install python-certbot-nginx
$ sudo certbot --nginx -d your-domain -d www.your-domain
```

After running tests to ensure you own the domain it will offer no redirect or redirect. Choose option 2 so that all insecure traffic is redirected. Once you have finsihed test the configuration and restart `Nginx`


```
$ sudo nginx -t
$ sudo systemctl restart nginx
```

You should now be able to navigate to your domain in the browser and see you domain is always running under `ssl`.

In Part 2 we will build a simple `Phoenix` aplication and deploy it to the server. 

<span class="pt-20"></span>