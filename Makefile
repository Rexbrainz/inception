##############################################################
#							INCEPTION						 #
##############################################################						
MARIADB_DIR = /home/sudaniel/data/mariadb
WORDPRESS_DIR = /home/sudaniel/data/wordpress


up:
	@mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)
	cd srcs && docker compose -f compose.yaml up -d --build

down:
	cd srcs && docker compose -f compose.yaml down

clean:
	cd srcs && docker compose down --rmi all --volumes
fclean:
	@sudo rm -rf $(MARIADB_DIR) $(WORDPRESS_DIR)
re:	fclean up

.PHONY:	up down clean fclean re

