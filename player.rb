module WarriorActions
    def low_health?
        health < 9
    end
end

class PreviousState < Struct.new(:health); end

class Action
    attr_reader :warrior, :prev_state

    def initialize(warrior, prev_state)
        @warrior = warrior
        @prev_state = prev_state
    end

    def take_control?
        raise "Implement me"
    end

    def being_attacked?
        prev_state && warrior.health < prev_state.health
    end
end

class DefendAction < Action
    def take_control?
        being_attacked? && warrior.low_health?
    end

    def execute
        warrior.walk! :backward
    end
end

class AttackAction < Action
    def take_control?
        warrior.feel.enemy?
    end

    def execute
        warrior.attack!
    end
end

class RescueAction < Action
    def take_control?
        warrior.feel.captive?
    end

    def execute
        warrior.rescue!
    end
end


class DefaultAction < Action
    def take_control?
        true
    end

    def execute
        if warrior.health < 20
            warrior.rest!
        else
            warrior.walk!
        end
    end
end

class Player
    def play_turn(warrior)
        @warrior = warrior
        warrior.extend(WarriorActions)

        action = [DefendAction, AttackAction, RescueAction, DefaultAction].map { |cls|
            cls.new(warrior, @prev_warrior)
        }.find(&:take_control?)
        action.execute
        save_state!
    end

    def save_state!
        @prev_warrior = PreviousState.new(@warrior.health)
    end
end
