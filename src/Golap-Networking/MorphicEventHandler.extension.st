Extension { #name : #MorphicEventHandler }

{ #category : #'*Golap-Networking' }
MorphicEventHandler >> clearAllSubscriptionsToEvent: eventName [
	subscriptions removeKey: eventName ifAbsent: [  ]
]
