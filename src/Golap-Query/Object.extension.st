Extension { #name : #Object }

{ #category : #'*Golap-Query' }
Object >> asGolapQuery [
	^ String streamContents: [ :stream | self printGolapQueryOn: stream ]
]

{ #category : #'*Golap-Query' }
Object >> golapQueryChildren [
	^ Array new
]

{ #category : #'*Golap-Query' }
Object >> printGolapQueryOn: aStream [
	self printOn: aStream
]
