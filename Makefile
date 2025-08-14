#############################################################
#							INCEPTION						 #
##############################################################						
MARIADB_DIR = /home/sudaniel/data/mariadb
WORDPRESS_DIR = /home/sudaniel/data/wordpress


up:
	@mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)
	cd srcs && docker compose -f compose.yaml build --no-cache
	cd srcs && docker compose -f compose.yaml up -d

down:
	cd srcs && docker compose -f compose.yaml down

clean:
	cd srcs && docker compose down --rmi all --volumes --remove-orphans

fclean: clean
	@sudo rm -rf home/sudaniel/data

re:	fclean up

.PHONY:	up down clean fclean re

