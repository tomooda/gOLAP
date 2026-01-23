Extension { #name : 'CocoaMenuItem' }

{ #category : '*Golap-UI' }
CocoaMenuItem class >> fromMenuSpec: aMenuSpec [

	^ self new fromMenuSpec: aMenuSpec
]

{ #category : '*Golap-UI' }
CocoaMenuItem >> fromMenuSpec: aMenuSpec [

	self
		title: (aMenuSpec label ifNil: [ '' ]);
		action: (aMenuSpec action ifNil: [ [ ] ]);
		shortcut: ''
]
