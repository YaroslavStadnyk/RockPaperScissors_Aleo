program rockpaperscissors.aleo 
{
    // rock: 0
    // paper: 1
    // scizzors: 2

    record issued_challenge
    {
        owner: address,
        challenger: address,
        challenger_selection_hash: field,
    }

    transition issue_challenge(selection: u64, salt: scalar, acceptor: address) -> issued_challenge
    {
        let challenger: address = self.caller;
        let challenger_selection_hash: field = BHP256::commit_to_field(selection, salt);
        return issued_challenge 
        {
            owner: self.caller,
            challenger: challenger,
            challenger_selection_hash: challenger_selection_hash,
        };
    }

    record accepted_challenge
    {
        owner: address,
        challenger_selection_hash: field,
        acceptor: address,
        acceptor_selection: u64,
    }

    transition accept_challenge(selection: u64, issued_challenge: issued_challenge) -> accepted_challenge
    {
        let challenger_selection_hash: field = issued_challenge.challenger_selection_hash;
        let acceptor: address = self.caller;
        let acceptor_selection: u64 = selection;
        return accepted_challenge
        {
            owner: self.caller,
            challenger_selection_hash: challenger_selection_hash,
            acceptor: acceptor,
            acceptor_selection: selection,
        };
    }

    record completed_challenge
    {
        owner: address,
        challenger: address,
        challenger_selection: u64,
        challenger_salt: scalar,
        acceptor: address,
        acceptor_selection: u64,
        winner: address,
    }

    transition complete_challenge(selection: u64, salt: scalar, accepted_challenge: accepted_challenge) -> (completed_challenge, completed_challenge)
    {
        let challenger_selection_hash: field = BHP256::commit_to_field(selection, salt);
        assert_eq(challenger_selection_hash, accepted_challenge.challenger_selection_hash);

        let challenger: address = self.caller;
        let challenger_selection: u64 = selection;
        let challenger_salt: scalar = salt;
        let acceptor: address = accepted_challenge.acceptor;
        let acceptor_selection: u64 = accepted_challenge.acceptor_selection;
        let winner: address = determine_winner(challenger, challenger_selection, acceptor, acceptor_selection);
        return (completed_challenge
        {
            owner: challenger,
            challenger: challenger,
            challenger_selection: selection,
            challenger_salt: salt,
            acceptor: acceptor,
            acceptor_selection: acceptor_selection,
            winner: winner,
        }, completed_challenge
        {
            owner: acceptor,
            challenger: challenger,
            challenger_selection: selection,
            challenger_salt: salt,
            acceptor: acceptor,
            acceptor_selection: acceptor_selection,
            winner: winner,
        });
    }

    const nullable_address: address = aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc;

    function determine_winner(challenger: address, challenger_selection: u64, acceptor: address, acceptor_selection: u64) -> address
    {
        let p1: u64 = challenger_selection % 3u64;
        let p2: u64 = acceptor_selection % 3u64;
        if (p1 == p2)
        {
            return nullable_address;
        }

        // it returns 1 if player1 wins, 2 if player2 wins, 0 for a tie.
        let w: u64 = (3u64 + p1 - p2) % 3u64;
        if (w == 1u64)
        {
            return challenger;
        }
        else if (w == 2u64)
        {
            return acceptor;
        }
        else
        {
            return nullable_address;
        }
    }
}
