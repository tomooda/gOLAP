Extension { #name : #PluggableMultiColumnListMorph }

{ #category : #'*Golap-UI' }
PluggableMultiColumnListMorph >> click: aMouseEvent [
	| row |
	row := self rowAtLocation: aMouseEvent position.
	row = 0
		ifTrue: [ ^ super click: aMouseEvent ].
	self mouseDownRow: row.
	self isMultipleSelection
		ifTrue: [ self mouseDownOnMultiple: aMouseEvent forRow: row ].
	^ super click: aMouseEvent
]
