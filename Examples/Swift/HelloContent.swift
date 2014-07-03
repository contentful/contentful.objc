#!/usr/bin/env swift -i

import ContentfulDeliveryAPI

var client = CDAClient()

client.fetchEntryWithIdentifier("nyancat",
    success: { (response: CDAResponse!, entry: CDAEntry!) -> Void in
        println(entry.fields)
    },
    failure: { (response: CDAResponse!, error: NSError!) -> Void in println(error) })
