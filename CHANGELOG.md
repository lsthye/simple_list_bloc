## v0.2.0 - 2021-08-07

* update dependency for flutter 2.2.3
* nullsafety

## v0.1.1 - 2021-04-22

* should reset `hasReachedMax` to `false` when refresh with `clear:true` flag

## v0.1.0 - 2021-03-10

* update dependency for flutter 2.0

## v0.0.7 - 2020-10-27

* remove `currentstate` parameter from `ListBloc`'s method as `state` were exposed from extended `Bloc` object

## v0.0.6 - 2020-10-19

* fix `ListStateBuilder` caused `ListView` didn't preserve it's scroll position after loading next page
* `SelectionStreamBuilder`'s builder pass `ListSelectionBloc` as parameter

## v0.0.5 - 2020-10-17

* `fetch` should call `sortItems` after fetch

## v0.0.4 - 2020-10-13

* make start bulk select target optional

## v0.0.3 - 2020-10-13

* remove event subject, use map for selection bloc

## v0.0.2 - 2020-10-12

* Add `hasItem` method to list bloc for checking if list contains target item

## v0.0.1 - 2020-10-11

* Initial Release
