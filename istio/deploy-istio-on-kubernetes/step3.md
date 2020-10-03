This example deploys a sample application composed of four separate microservices used to demonstrate various Istio features.

The Bookinfo application is broken into four separate microservices:

* productpage. The productpage microservice calls the details and reviews microservices to populate the page.
* details. The details microservice contains book information.
* reviews. The reviews microservice contains book reviews. It also calls the ratings microservice.
* ratings. The ratings microservice contains book ranking information that accompanies a book review.

![](https://istio.io/latest/docs/examples/bookinfo/noistio.svg)