module MachikadoNetwork::Invite {
    struct Invite has store, drop {
        // Who invites me
        inviter: address,
        used: bool
    }

    public fun new(inviter: address): Invite {
        Invite {
            inviter,
            used: false,
        }
    }

    public fun set_used(invite: &Invite, used: bool): Invite {
        Invite {
            inviter: invite.inviter,
            used,
        }
    }

    public fun get_inviter(invite: &Invite): address {
        invite.inviter
    }

    public fun is_used(invite: &Invite): bool {
        invite.used
    }
}
