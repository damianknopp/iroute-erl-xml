#!/bin/sh


echo erl -noshell -s message_parser run -s init stop
erl -noshell -smp -s message_parser run -s init stop
