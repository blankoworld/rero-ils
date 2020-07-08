/// <reference types="Cypress" />
/*

RERO ILS
Copyright (C) 2020 RERO

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

*/

function getCurrentDateAndHour() {
    let today = new Date()
    let date = today.getFullYear() + '-' + today.getMonth() + '-' + today.getDay()
    let time = today.getHours() + 'H' + today.getMinutes()
    return date + 'T' + time
}

describe('Scenario A (standard loan)', function () {
    it('Makes a request on on-shelf item', function() {
        // DESCRIPTION
        // ===========
        // A request is made on on-shelf item, that has no requests, 
        // to be picked up at the owning library.
        // Validated by the librarian.
        // Picked up at same owning library.
        // And returned on-time at the owning library.

        // SET UP the application state: create a new item
        // Use a specific preview size, specific language
        cy.setup()
        // Login as admin
        cy.adminLogin('reroilstest+virgile@gmail.com', '123456')

        // Create a new item
        let currentDate = getCurrentDateAndHour()
        let barcode = currentDate + '_scenarioA'
        cy.createItem(barcode, 'Standard', 'Espaces publics')

        // Logout librarian and login as normal user
        cy.logout()
        cy.login('reroilstest+simonetta@gmail.com', '123456')
        
        // Search previous item
        cy.goToItem(barcode)
        
        cy.get(':nth-child(2) > .offset-1 > .row > .col > #dropdownMenu > .fa').click()

        // Request it
        cy.pause()

    })

    // WHAT you always have to do in tests:
    // 1) set up the application state
    // 2) take an action
    // 3) make an assertion
})