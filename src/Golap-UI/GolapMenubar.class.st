Class {
	#name : 'GolapMenubar',
	#superclass : 'MenubarMorph',
	#category : 'Golap-UI-Menus',
	#package : 'Golap-UI',
	#tag : 'Menus'
}

{ #category : 'instance creation' }
GolapMenubar class >> menuBuilder [

	^ PragmaMenuBuilder pragmaKeyword: #golapMenu model: self
]

{ #category : 'instance creation' }
GolapMenubar class >> open [

	<script>
	| menu menuItems |
	menu := self menuBuilder menuSpec.
	menuItems := menu items first subMenu items.
	self new
		menuBarItems: menuItems;
		open.
	OSPlatform current isMacOSX ifTrue: [
			Smalltalk
				at: #CocoaMenu
				ifPresent: [ :cocoaMenu |
				(CocoaMenu fromMenuSpec: menu) setAsMainMenu ] ]
]

{ #category : 'class initialization' }
GolapMenubar class >> reset [

	<script>
	self closeAll.
	self open
]

{ #category : 'adding' }
GolapMenubar >> add: wordingString icon: aForm help: helpString enabled: aBoolean subMenu: aMenuMorph action: anAction keyText: aText [
	"Append the given submenu with the given label."

	| item |
	item := self newMenuItem
		        contents: wordingString;
		        subMenu: aMenuMorph;
		        icon: aForm;
		        enabled: aBoolean;
		        keyText: aText;
		        yourself.
	anAction ifNotNil: [ :act |
			item
				target: act receiver;
				selector: act selector;
				arguments: act arguments ].
	helpString ifNotNil: [ item setBalloonText: helpString ].
	self addMorphBack: item
]

{ #category : 'accessing' }
GolapMenubar >> open [
	self menuBarItems
		do: [ :each |
			self
				add: each label
				icon: each icon
				help: each help
				enabled: each enabled
				subMenu: (each subMenu ifNotNil: #asMenubarMenuMorph)
				action: each action
				keyText: each keyText.
			each separator
				ifTrue: [ self addSeparator ] ].
	self
		adhereToTop;
		openInWorld
]
