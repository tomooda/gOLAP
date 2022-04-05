Extension { #name : #Number }

{ #category : #'*Golap-Models' }
Number >> ifNaN: aBlock [
	self isNaN
		ifTrue: [ ^ aBlock value ]
]
