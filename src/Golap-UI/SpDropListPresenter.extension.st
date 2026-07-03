Extension { #name : 'SpDropListPresenter' }

{ #category : '*Golap-UI' }
SpDropListPresenter >> items: aCollection selectItem: anObject [

	| realItem |
	self setCollection: aCollection.
	realItem := model collection detect: [ :each | each model = anObject ].
	self selection selectItem: realItem
]

{ #category : '*Golap-UI' }
SpDropListPresenter >> selectItem: anItem [
	"Select the element `anItem` if it is in the list. 
	 It executes the action associated with the item if it is defined."

	| realItem |
	anItem ifNil: [
			self selection unselectAll.
			^ self ].

	realItem := model collection
		            detect: [ :each | each model = anItem ]
		            ifNone: [ ^ self ].
	self selection selectItem: realItem.
	"I execute the block associated with the item"
	realItem value
]
