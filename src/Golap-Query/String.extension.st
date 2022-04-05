Extension { #name : #String }

{ #category : #'*Golap-Query' }
String >> golapQuoted [
	"'abc''def' golapQuoted >>> '''abc\''def'''"

	^ self class
		streamContents: [ :stream | 
			stream nextPut: $'.
			self
				do: [ :char | 
					(char = $\ or: [ char = $' ])
						ifTrue: [ stream nextPut: $\ ].
					stream nextPut: char ].
			stream nextPut: $' ]
]

{ #category : #'*Golap-Query' }
String >> printGolapQueryOn: aStream [
	aStream nextPut: $".
	self
		do: [ :char | 
			char = $"
				ifTrue: [ aStream nextPutAll: '\"' ]
				ifFalse: [ aStream nextPut: char ] ].
	aStream nextPut: $"
]
