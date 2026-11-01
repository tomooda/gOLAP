Class {
	#name : 'GolapNoteReplaced',
	#superclass : 'Announcement',
	#instVars : [
		'oldNote',
		'newNote'
	],
	#category : 'Golap-Notepad-Core',
	#package : 'Golap-Notepad',
	#tag : 'Core'
}

{ #category : 'accessing' }
GolapNoteReplaced >> newNote [

	^ newNote
]

{ #category : 'accessing' }
GolapNoteReplaced >> newNote: aGolapNote [

	newNote := aGolapNote
]

{ #category : 'accessing' }
GolapNoteReplaced >> oldNote [

	^ oldNote
]

{ #category : 'accessing' }
GolapNoteReplaced >> oldNote: aGolapNote [

	oldNote := aGolapNote
]
