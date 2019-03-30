check:
	- mix test
	- mix dialyzer

janus:
	- docker-compose up --build
