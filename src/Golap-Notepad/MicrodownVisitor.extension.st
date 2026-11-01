Extension { #name : 'MicrodownVisitor' }

{ #category : '*Golap-Notepad' }
MicrodownVisitor >> visitGolapClip: aMicGolapScriptBlock [

	^ aMicGolapScriptBlock children collect: [ :each | self visit: each ]
]
