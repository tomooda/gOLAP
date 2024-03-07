Class {
	#name : #GolapSunburstBuilder,
	#superclass : #RSSunburstBuilder,
	#category : #'Golap-Clustering'
}

{ #category : #strategy }
GolapSunburstBuilder >> extentStrategy [
	self strategy: GolapSunburstLayout new.
	^ strategy
]
