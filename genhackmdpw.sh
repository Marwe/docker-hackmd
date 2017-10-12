#!/bin/bash


function genrndstr {
n=$(($1+0))
if [ "$n" -lt 8 ] ; then n = 8 ;fi
tr -dc A-Za-z0-9_ < /dev/urandom | head -c $n
}

if [ ! -f ".env" ] ; then
	echo ".env not existing, creating with random passwords..."
	cp env.template .env
	sed -i -e "/POSTGRES_USER/s#.*#POSTGRES_USER=hackmd$(genrndstr 8)#g" .env
	sed -i -e "/POSTGRES_PASSWORD/s#.*#POSTGRES_PASSWORD=$(genrndstr 30)#g" .env
fi


if [ -d hackmdpw ] ; then
	mv -v hackmdpw "hackmdpw.bak.$(date -I).$(genrndstr 8)"
fi
cp -r hackmd hackmdpw


source .env

sed -i -e "s@PG_USER@$POSTGRES_USER@" hackmdpw/config.json hackmdpw/.sequelizerc
sed -i -e "s@PG_PASSWORD@$POSTGRES_PASSWORD@" hackmdpw/config.json hackmdpw/.sequelizerc
sed -i -e "s@PG_DB@$POSTGRES_DB@" hackmdpw/config.json hackmdpw/.sequelizerc

pushd hackmdpw
docker build -t hackmdpw .
popd
