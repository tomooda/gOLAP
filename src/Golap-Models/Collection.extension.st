Extension { #name : 'Collection' }

{ #category : '*Golap-Models' }
Collection >> maxWith: aBlock [

	| maxMember maxValue |
	maxMember := self anyOne.
	maxValue := aBlock value: maxMember.
	self do: [ :member |
		| value |
		value := aBlock value: member.
		value > maxValue ifTrue: [
			maxValue := value.
			maxMember := member ] ].
	^ maxMember
]
