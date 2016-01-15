#-------------------------------------------------------------------------------
# Copyright (c) 2010 Xilinx, Inc.
# All rights reserved.
#-------------------------------------------------------------------------------
#    ____  ____
#   /   /\/   /
#  /___/  \  /   Vendor: Xilinx
#  \   \   \/    Version:       
#   \   \        Filename: AXISysgenSubfieldsUtil.tcl
#   /   /        Date Last Modified: 07/05/10
#  /___/   /\    Generated by: Anindita Patra v1.1.0
#  \   \  /  \   
#   \___\/\___\
#
# This text contains proprietary, confidential information of Xilinx,Inc.,
# is distributed under license from Xilinx, Inc., and may be used, copied
# and/or disclosed only pursuant to the terms of a valid license agreement
# with Xilinx, Inc.
#
# This copyright notice must be retained as part of this text at all times.
#
#-------------------------------------------------------------------------------

namespace eval AXISysgenSubfieldsUtil {

    #
    # recursively creates one tcl list containing subfield info, depending on
    # the subfieldinfolist provided
    #   @param $subFieldInfoList : {$subFieldInfo1 $subFieldInfo2 ... }
    #                              $subFieldInfon can in turn contain similar subFieldInfoList, listing
    #                              information about its subfields
    #
    #   @returns : one tcl list containing subfield info for various subfields
    #
    proc buildAXItdataSubFieldInfo { subFieldInfoList } {
        set subFieldList [list]
        foreach subFieldInfo $subFieldInfoList {

            set subFieldData [list]

            set subFieldName [lindex $subFieldInfo 0]
            set subFieldType [lindex $subFieldInfo 1]
            set subFieldWidth [lindex $subFieldInfo 2]
            set subFieldActualWidth [lindex $subFieldInfo 3]
            set arithmeticType [lindex $subFieldInfo 4]
            set binaryPoint [lindex $subFieldInfo 5]

            lappend subFieldData [string tolower $subFieldName]
            lappend subFieldData [string tolower $subFieldType]
            lappend subFieldData $subFieldWidth
            lappend subFieldData $subFieldActualWidth
            lappend subFieldData [string tolower $arithmeticType]
            lappend subFieldData $binaryPoint

            if { [llength $subFieldInfo] >= 7 } {
                set period [lindex $subFieldInfo 6]
                lappend subFieldData $period
            }

            if { [llength $subFieldInfo] >= 8 } {
                set addnlSubFieldData [lindex $subFieldInfo 7]
                set addnlSubFieldDataRec [buildAXItdataSubFieldInfo $addnlSubFieldData]
                lappend subFieldData $addnlSubFieldDataRec
            }

            lappend subFieldList $subFieldData

        }

        return $subFieldList
    }

    #
    # creates one tcl list containing tdata-info for a tdata-pin
    #   @param $axi_class_name   : one of { Streaming MemoryMapped None }
    #   @param $data_class_name  : one of { Real Complex SingleFloat DoubleFloat Vector Parallel Composite }
    #                              - can be extended to include newer meaning, if required.
    #   @param $interface_width  : total width of TDATA signal, along with padding, can be "Null", if unknown
    #   @param $subFieldInfoList : list of corresponding info for each subfield {$subFieldInfo1 $subFieldInfo2 ... }
    #                              $subFieldInfon is from MSB to LSB of the interface information of TDATA subfields
    #
    #   @returns : one tcl list representing tdata-info for the TDATA pin
    #              tdata-info list structure { axi_class_name data_class_name interface_width subFieldInfoList }
    #
    proc buildOneAXItdataInfo { axi_class_name data_class_name interface_width subFieldInfoList } {
        set tdataInfo [list]
        lappend tdataInfo [string tolower $axi_class_name]
        lappend tdataInfo [string tolower $data_class_name]

        if {$interface_width != ""} {
            lappend tdataInfo $interface_width
        }

        if {$subFieldInfoList != ""} {
            if { [llength $subFieldInfoList] > 0 } {
                set subFieldDataRec [buildAXItdataSubFieldInfo $subFieldInfoList]
                lappend tdataInfo $subFieldDataRec
            }
        }

        return $tdataInfo
    }

    #
    # creates one tcl list containing subfield information for a subfield of the TDATA pin
    # or a parent subfield (a recursive description, as we can have subfield within subfield within subfields)
    #   @param $subFieldName        : name of the subfield
    #   @param $subFieldType        : one of "Atomic" or "Composite"
    #   @param $subFieldWidth       : bit positions occupied by the subfield "{MSBBit LSBBit}"
    #   @param $subFieldActualWidth : bit positions occupied by non-padded data
    #   @param $arithmeticType      : one of "bool", "unsigned" or "signed"
    #   @param $binaryPoint         : Sysgen binary point location
    #   @param $period              : Sysgen period information for configuring rate, can be "Null", if unknown
    #   @param $subFieldInfoList    : list of corresponding info for each subfield {$subFieldInfo1 $subFieldInfo2 ... }
    #                                 $subFieldInfon is from MSB to LSB of the interface information the parent subfield
    #                                 - can be "Null", if the subfield is an "Atomic" one.
    #
    #   @returns : one tcl list representing subfield-info for a subfield
    #              subfield-info list structure :
    #               {subfieldName subFieldType subFieldWidth subfieldActualWidth arithmeticType binaryPoint period subFieldInfoList}
    #
    proc buildOneAXItdataSubFieldInfo { subFieldName subFieldType subFieldWidth subFieldActualWidth arithmeticType binaryPoint { period "" } { subFieldInfoList "" } } {
        set subFieldInfo [list]
        lappend subFieldInfo  [string tolower $subFieldName]
        lappend subFieldInfo [string tolower $subFieldType]
        lappend subFieldInfo  $subFieldWidth
        lappend subFieldInfo $subFieldActualWidth
        lappend subFieldInfo [string tolower $arithmeticType]
        lappend subFieldInfo $binaryPoint

        if {$period != ""} {
            lappend subFieldInfo $period
        }

        if {$subFieldInfoList != ""} {
            if { [llength $subFieldInfoList] > 0 } {
                set subFieldDataRec [buildAXItdataSubFieldInfo $subFieldInfoList]
                lappend subFieldInfo $subFieldDataRec
            }
        }

        return $subFieldInfo
    }

    proc tdata_info {} {
        # for now, interpret 'binarypoint' as 'tdata_info'
        # after IP support, use 'tdata_info' or whatever other
        # attribute name that has been decided
        return "binarypoint"
    }

    #
    # returns axi-class name for a tdata-pin
    #   @param $port : one tdata pin
    #   @returns : axi-class name of the pin  - one of {Streaming MemoryMapped None}
    #
    proc getAXIClassName { port } {
        upvar $port tdata_pin
        set tdataInfo   [$tdata_pin GetProperty [tdata_info] ]
        if { [llength $tdataInfo] >= 1 } {
            return [lindex $tdataInfo 0]
        } else {
            return "ERROR"
        }
    }

    #
    # returns data-class name for a tdata-pin
    #   @param $port : one tdata pin
    #   @returns : data-class name of the pin  - one of 
    #              {Real Complex SingleFloat DoubleFloat Vector Parallel Composite}
    #              - can be extended to include newer meaning, if required
    #
    proc getDataClassName { port } {
        upvar $port tdata_pinbuildOneAtomicSubFieldInfo
        set tdataInfo   [$tdata_pin GetProperty [tdata_info] ]
        if { [llength $tdataInfo] >= 2 } {
            return [lindex $tdataInfo 1]
        } else {
            return "ERROR"
        }
    }

    #
    # returns interface width for a tdata-pin
    #   @param $port : one tdata pin
    #   @returns : total width of TDATA signal, along with padding, can be "Null", if unknown
    #
    proc getInterfaceWidth { port } {
        upvar $port tdata_pin
        set tdataInfo   [$tdata_pin GetProperty [tdata_info] ]
        if { [llength $tdataInfo] >= 3 } {
            return [lindex $tdataInfo 2]
        } else {
            return "ERROR"
        }
    }

    #
    # sets interface width for a tdata-pin
    #   @param $port   : one tdata pin
    #   @param $newVal : new value for the total width of the tdata-pin
    #   @returns : "OK", if the update is successful, else "ERROR"
    #
    proc setInterfaceWidth { port newVal } {
        upvar $port tdata_pin
        set tdataInfo   [$tdata_pin GetProperty [tdata_info] ]
        if { [llength $tdataInfo] >= 3 } {
            lset tdataInfo 2 $newVal
            $tdata_pin SetProperty [tdata_info] $tdataInfo
            return "OK"
        } else {
            return "ERROR"
        }
    }

    #
    # returns a list containing subfieldinfo of each subfield of a tdata-pin - each
    # subFieldInfo may be a recursive description, as we can have subfield within subfield within subfields
    #   @param $port : one tdata pin
    #   @returns : list of subfield info {subFieldInfo1 subFieldInfo2 ...} from MSB to lSB of the tdata pin 
    #
    proc getAXItdataSubFieldInfoList { port } {
        upvar $port tdata_pin
        set tdataInfo   [$tdata_pin GetProperty [tdata_info] ]
        if { [llength $tdataInfo] >= 4 } {
            return [lindex $tdataInfo 3]
        } else {
            return "ERROR"
        }
    }

    #
    # returns the particular property-value, of the particular subfield, for an AXI tdata-pin
    #   @param $port         : one tdata pin
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @param $propertyName : name of the property (for e.g. subFieldWidth /
    #                          arithmeticType / binaryPoint etc.) of the subfield
    #   @returns : returns particular property-value, requested for the subfield -
    #              for invalid property, returns "ERROR"
    #
    proc getAXItdataSubfieldProperty { port subFieldName propertyName } {
        upvar $port tdata_pin
        set subFieldInfoList [ getAXItdataSubFieldInfoList tdata_pin ]
        foreach subFieldInfo $subFieldInfoList {
            set name [ getSubFieldName $subFieldInfo ]
            if { [string equal -nocase $subFieldName $name] } {
                set retVal [ getSubfieldProperty $subFieldInfo $propertyName ]
                return $retVal
            }
        }
    }

    #
    # sets the particular property-value of the particular subfield, for an AXI tdata_pin
    #   @param $port         : one tdata pin
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @param $propertyName : name of the property (for e.g. subFieldWidth /
    #                          arithmeticType / binaryPoint etc.) of the subfield
    #   @param $newVal       : new value for the property
    #   @returns : "OK" if update for the particular property of the subfield is successful
    #              else "ERROR"
    #
    #
    proc setAXItdataSubfieldProperty { port subFieldName propertyName newVal } {
        upvar $port tdata_pin
        set pin_info [$tdata_pin GetProperty [tdata_info]] 
        set subFieldInfoList [ getAXItdataSubFieldInfoList tdata_pin ]
        set newSubFieldInfoList $subFieldInfoList
        set i -1 
        foreach subFieldInfo $subFieldInfoList {
            incr i
            set name [ getSubFieldName $subFieldInfo ]
            if { [string equal -nocase $subFieldName $name] } {
                set retVal [ setSubfieldProperty subFieldInfo $propertyName $newVal ]
                lset newSubFieldInfoList $i $subFieldInfo
                lset pin_info 3 $newSubFieldInfoList
                $tdata_pin SetProperty [tdata_info] $pin_info
                return $retVal 
            }
        }
    }

    #
    # returns the particular property-value, requested for a subfield
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @param $propertyName : name of the property (for e.g. subFieldWidth /
    #                          arithmeticType / binaryPoint etc.) of the subfield
    #   @returns : returns particular property-value, requested for the subfield -
    #              for invalid property, returns "ERROR"
    #
    proc getSubfieldProperty { subFieldInfo propertyName } {
        set status ""
        if { [string equal -nocase $propertyName "subFieldName"] } {
            set status [ getSubFieldName $subFieldInfo ]
        } elseif { [string equal -nocase $propertyName "subFieldType"] } {
            set status [ getSubFieldType $subFieldInfo ]
        } elseif { [string equal -nocase $propertyName "subFieldWidth"] } {
            set status [ getSubFieldWidth $subFieldInfo ]
        } elseif { [string equal -nocase $propertyName "subFieldActualWidth"] } {
            set status [ getSubFieldActualWidth $subFieldInfo ]
        } elseif { [string equal -nocase $propertyName "arithmeticType"] } {
            set status [ getSubFieldArithType $subFieldInfo ]
        } elseif { [string equal -nocase $propertyName "binaryPoint"] } {
            set status [ getSubFieldBinPt $subFieldInfo ]
        } elseif { [string equal -nocase $propertyName "period"] } {
            set status [ getSubFieldPeriod $subFieldInfo ]
        } elseif { [string equal -nocase $propertyName "subFieldInfoList"] } {
            set status [ getSubFieldInfoList $subFieldInfo ]
        } else {
            set status "ERROR"
        }
	return $status
    }

    #
    # sets the particular property-value, requested for a subfield
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @param $propertyName : name of the property (for e.g. subFieldWidth /
    #                          arithmeticType / binaryPoint etc.) of the subfield
    #   @param $newVal       : new value for the property
    #   @returns : "OK" if update for the particular property of the subfield is successful
    #              else "ERROR"
    #
    #
    proc setSubfieldProperty { oneSubField propertyName newVal } {
        upvar $oneSubField subFieldInfo
        set status ""
        if { [string equal -nocase $propertyName "subFieldWidth"] } {
            set status [ setSubFieldWidth subFieldInfo $newVal ]
        } elseif { [string equal -nocase $propertyName "arithmeticType"] } {
            set status [ setSubFieldArithType subFieldInfo $newVal ]
        } elseif { [string equal -nocase $propertyName "binaryPoint"] } {
            set status [ setSubFieldBinPt subFieldInfo $newVal ]
        } elseif { [string equal -nocase $propertyName "period"] } {
            set status [ setSubFieldPeriod subFieldInfo $newVal ]
        } elseif { [string equal -nocase $propertyName "subFieldInfoList"] } {
            set status [ setSubFieldInfoList subFieldInfo $newVal ]
        } elseif { [string equal -nocase $propertyName "subFieldActualWidth"] } {
            set status [ setSubFieldActualWidth subFieldInfo $newVal ]
        } else {
            set status "ERROR"
        }
        return $status
    }

    #
    # returns name of a subfield
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : name of the subfield
    #
    proc getSubFieldName { subFieldInfo } {
        if { [llength $subFieldInfo] >= 1 } {
            return [lindex $subFieldInfo 0]
        } else {
            return "ERROR"
        }
    }

    #
    # returns type of a subfield
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : returns type (atomic or composite) of a subfield 
    #
    proc getSubFieldType { subFieldInfo } {
        if { [llength $subFieldInfo] >= 2 } {
            return [lindex $subFieldInfo 1]
        } else {
            return "ERROR"
        }
    }

    #
    # returns true, if the subfield is of type "Atomic" i.e. does not have any other
    # subfield within it, else returns false
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : returns true, if the type of the subfield is "atomic", else returns false
    #
    proc isAtomicSubField { subFieldInfo } {
        if { [llength $subFieldInfo] >= 2 } {
            set subFieldType [lindex $subFieldInfo 1]
            if { [string equal -nocase $subFieldType "atomic"] } { return true }
            else { return false }
        } else {
            return "ERROR"
        }
    }

    #
    # returns bit positions occupied by the non-padded data
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : bit positions occupied by the non-padded subfield-data
    #
    proc getSubFieldWidth { subFieldInfo } {
        if { [llength $subFieldInfo] >= 3 } {
            return [lindex $subFieldInfo 2]
        } else {
            return "ERROR"
        }
    }

    #
    # sets bit positions occupied by the non-padded data
    #   @param $oneSubField : one tcl list, representing information for a subfield
    #   @param $newVal      : new width value, representing the bit positions occupied 
    #                         by the non-padded subfield-data
    #   @returns : "OK", if successful, else "ERROR"
    #
    proc setSubFieldWidth { oneSubField newVal } {
        upvar $oneSubField subFieldInfo
        if { [llength $subFieldInfo] >= 3 } {
            lset subFieldInfo 2 $newVal
            return "OK"
        } else {
            return "ERROR"
        }
    }

    #
    # returns bit positions (may contain padding) occupied by the data
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : bit positions occupied by the padded data
    #
    proc getSubFieldActualWidth { subFieldInfo } {
        if { [llength $subFieldInfo] >= 4 } {
            return [lindex $subFieldInfo 3]
        } else {
            return "ERROR"
        }
    }

    #
    # sets bit positions occupied by the padded subfield-data
    #   @param $oneSubField : one tcl list, representing information for a subfield
    #   @param $newVal      : new width value, representing the bit positions occupied 
    #                         by the padded subfield-data
    #   @returns : "OK", if successful, else "ERROR"
    #
    proc setSubFieldActualWidth { oneSubField newVal } {
        upvar $oneSubField subFieldInfo
        if { [llength $subFieldInfo] >= 4 } {
            lset subFieldInfo 3 $newVal
            return "OK"
        } else {
            return "ERROR"
        }
    }
    #
    # returns arithmeticType of a subfield
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : one of "bool", "signed" or "unsigned"
    #
    proc getSubFieldArithType { subFieldInfo } {
        if { [llength $subFieldInfo] >= 5 } {
            return [lindex $subFieldInfo 4]
        } else {
            return "ERROR"
        }
    }

    #
    # sets arithmeticType of a subfield
    #   @param $oneSubField : one tcl list, representing information for a subfield
    #   @param $newVal      : one of "bool", "signed" or "unsigned"
    #   @returns : "OK", if successful, else "ERROR"
    #
    proc setSubFieldArithType { oneSubField newVal } {
        upvar $oneSubField subFieldInfo
        if { [llength $subFieldInfo] >= 5 } {
            lset subFieldInfo 4 $newVal
            return "OK"
        } else {
            return "ERROR"
        }
    }

    #
    # returns Sysgen binary point location for a subfield
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : binary point location of the subfield
    #
    proc getSubFieldBinPt { subFieldInfo } {
        if { [llength $subFieldInfo] >= 6 } {
            return [lindex $subFieldInfo 5]
        } else {
            return "ERROR"
        }
    }

    #
    # sets binary point location of a subfield
    #   @param $oneSubField : one tcl list, representing information for a subfield
    #   @param $newVal      : new binary point location for the subfield
    #   @returns : "OK", if successful, else "ERROR"
    #
    proc setSubFieldBinPt { oneSubField newVal } {
        upvar $oneSubField subFieldInfo
        if { [llength $subFieldInfo] >= 6 } {
            lset subFieldInfo 5 $newVal
            return "OK"
        } else {
            return "ERROR"
        }
    }

    #
    # returns Sysgen period of a subfield
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : period of the subfield, can be "Null", if unknown
    #
    proc getSubFieldPeriod { subFieldInfo } {
        if { [llength $subFieldInfo] >= 7 } {
            return [lindex $subFieldInfo 6]
        } else {
            return "ERROR"
        }
    }

    #
    # sets period of a subfield
    #   @param $oneSubField : one tcl list, representing information for a subfield
    #   @param $newVal      : new period value, for the subfield
    #   @returns : "OK", if successful, else "ERROR"
    #
    proc setSubFieldPeriod { oneSubField newVal } {
        upvar $oneSubField subFieldInfo
        if { [llength $subFieldInfo] >= 7 } {
            lset subFieldInfo 6 $newVal
            return "OK"
        } else {
            return "ERROR"
        }
    }

    #
    # returns a list containing subfieldinfo of each subfield of a composite subfield - each
    # subFieldInfo may be a recursive description, as we can have subfield within subfield
    # within subfields - for an atomic subfield, attempt to retireve this is an error case
    #   @param $subFieldInfo : one tcl list, representing information for a subfield
    #   @returns : list of subfield info {subFieldInfo1 subFieldInfo2 ...} from MSB to lSB of the subField 
    #
    proc getSubFieldInfoList { subFieldInfo } {
        set isAtomic [isAtomicSubField $subFieldInfo]
        if { isAtomic == true || [llength $subFieldInfo] < 8 } {
            return "ERROR"
        } else {
            return [lindex $subFieldInfo 7]
        }
    }

    #
    # sets a list containing subfieldinfo of each subfield, to a subfield - each
    # subFieldInfo may be a recursive description, as we can have subfield within
    # subfield within subfields - for an atomic subfield, attempt to set this info is an error case
    #   @param $oneSubField         : one tcl list, representing information for a subfield
    #   @param $newSubFieldInfoList : one tcl list, containing new subfield info {subFieldInfo1 subFieldInfo2 ...}
    #                                 from MSB to lSB of the subField 
    #   @returns : "OK", if successful, else "ERROR"
    #
    proc setSubFieldInfoList { oneSubField newSubFieldInfoList} {
        upvar $oneSubField subFieldInfo
        set isAtomic [isAtomicSubField $subFieldInfo]
        if { isAtomic == true || [llength $subFieldInfo] < 8 } {
            return "ERROR"
        } else {
            lset subFieldInfo 7 $newSubFieldInfoList
            return "OK"
        }
    }

}