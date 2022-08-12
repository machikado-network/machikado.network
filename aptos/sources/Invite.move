module MachikadoNetwork::Invite {
    struct Invite has store {
        // Who invites me
        inviter: address,
    }

    public fun new(inviter: address): Invite {
        Invite {
            inviter
        }
    }

    public fun get_inviter(invite: &Invite): address {
        invite.inviter
    }
}
