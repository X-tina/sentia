# Dependencies
<p> ruby "3.2.7"<p>
<p> rails "7.0.8"<p>
<p> pg <p>
<p> react "19.0.0" <p>
<p> docker <p>

# Setup and run
docker compose app --build

# Access to interactive shell
```docker compose exec -it sentia_api /bin/bash ```

```docker compose run sentia_api rails db:create db:migrate```

# Navigate
```frontend: http://localhost:5173 ```

``` backend  http://localhost:3000 ```
