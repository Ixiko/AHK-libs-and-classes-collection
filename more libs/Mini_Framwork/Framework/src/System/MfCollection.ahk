;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}
/*
	Class: MfCollection
		Provides the class for a strongly typed collection.
	Inherits: MfCollectionBase
*/
class MfCollection extends MfCollectionBase
{
;{ Constructor
/*
	Constructor: ()
		Constructor for MfCollection. Creates a new instance of MfCollection class
*/
	__New() {
		base.__New()
		this.m_isInherited := this.__Class != "MfCollection"
	}
; End:Constructor ;}	

}
/*!
	End of class
*/