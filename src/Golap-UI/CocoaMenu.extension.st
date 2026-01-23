Extension { #name : 'CocoaMenu' }

{ #category : '*Golap-UI' }
CocoaMenu class >> fromMenuSpec: aMenuSpec [

	(aMenuSpec isKindOf: PluggableMenuSpec) ifTrue: [
		^ self new fromMenuSpec: aMenuSpec ].
	aMenuSpec subMenu ifNotNil: [ :subMenu |
			^ (self new fromMenuSpec: subMenu)
				  title: aMenuSpec label;
				  yourself ].
	^ CocoaMenuItem fromMenuSpec: aMenuSpec
]

{ #category : '*Golap-UI' }
CocoaMenu >> fromMenuSpec: aMenuSpec [

	self title: (aMenuSpec label ifNil: [ '' ]).
	aMenuSpec items do: [ :menuSpec |
		self add: (self class fromMenuSpec: menuSpec) ]
]
